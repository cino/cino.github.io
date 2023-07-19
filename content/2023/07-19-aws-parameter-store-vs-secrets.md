+++
author = "Ricardo Cino"
title = "AWS Parameter Store vs AWS Secrets"
slug = "aws-parameter-store-vs-aws-secrets"
date = "2023-07-19"
tags = [
    "aws",
    "amazon web services",
    "parameter store",
    "secrets",
    "serverless",
    "lambda",
    "cloudwatch event",
    "rotation"
]
+++

Recently I've been using AWS Secrets to retrieve API keys which are needed to access external API's, however, this turned out to be a more expensive service than we initially thought when starting.

<!--more-->
<img src="/img/2023/aws-parameter-store-vs-secrets/secrets-vs-parameter-store.png">

## Parameter Store vs Secrets

When you need to store and use variables/secrets within AWS, you'll have several services at your disposal to ensure secure and efficient management. The two primary services for this purpose are AWS Systems Manager Parameter Store and AWS Secrets Manager. AWS Systems Manager Parameter Store is ideal for storing non-sensitive configuration data, such as database connection strings and application settings. It offers both plaintext and encrypted options, along with basic access control using IAM policies.

On the other hand, AWS Secrets Manager is specifically designed to handle sensitive information like API keys, database credentials, and other secrets. It automatically encrypts the data using AWS KMS and provides more granular access control through IAM policies, even allowing for secret rotation to enhance security. By choosing the appropriate service for your specific use case, you can ensure the protection of your variables and secrets while seamlessly integrating them into your AWS applications and services.

However, if you look at the encrypted option for Parameter Store and compare it with Secrets you'll quickly realize that when you **don't'** make use of the rotation feature in AWS Secrets it is actually a very expensive Parameter Store.

_All the code examples on this page are available as ready-to-deploy cdk on my <a href="https://github.com/cino/cdk-examples/tree/main/parameter-store-vs-secret" target="_blank">CDK Examples</a> repository._

## Why use Parameter Store?

The Parameter Store is a service that is used to store variables and secrets, it is a very simple service to use and it is very cheap. The Parameter Store is a service that is part of the AWS Systems Manager, this is a great place to store variables that you want to use in your code but don't want to hardcore. For example you could store the API key of a external service in the Parameter Store and retrieve it in your code, another example could be the identifiers/keys for specific resources in your AWS account.

Because you can retrieve this during rungtime (and cache them for limited time) you always the latest version of the parameter, compared to storing such values in Lambda Environments or in a file on the EC2 instance.


## When to use AWS Secrets?

What makes AWS Secrets such a powerfool tool is that it seamlessly integrates with a couple of Amazon products, for example you can easily use an AWS Secret to rotate the password of your Aurora instance without writing a single line of code. A couple of AWS Services that are supported by this are: Amazon RDS, Amazon DocumentDB and Amazon Redshift. Next to the out-of-the-box support services AWS also provides with a few rotation lambda templates on their <a href="https://github.com/aws-samples/aws-secrets-manager-rotation-lambdas/tree/master" target="_blank">GitHub</a>.

In the case of a custom secret the only time to use AWS Secrets would be when you actually are rotating the values on a regular basis, the mechanism provided by Amazon is amazing and with automatic failure handling/retry handling it works better than with the Parameter Store.

For any secret you are not rotating I would advise to use the Parameter Store as this is much cheaper when you are using it a lot.


## But... you can also rotate the value with Parameter Store.

Absolutely! This would however be a complete custom integration with a scheduled lambda that modifies the value of the Parameter. In fact this is the same thing that you do when using the Rotation feature of AWS Secrets except it is much more simplified. For starters you would need to deploy a Lambda Function with the permissions to read and write to the specific Parameter.

CDK:
```typescript
const secretParameter = StringParameter.fromSecureStringParameterAttributes(this, 'mySecretRotatingParameter', {
  parameterName: '/parameter-store-vs-secret/secret-rotating',
});

// It is not possible to get the output of the secret value from the AWS CDK.
// However you can give lambda's permission to read/write the secret value.

// In this example we will be rotating the secret every 5 minutes to demonstrate the rotation.
const rotationLambda = new NodejsFunction(this, 'rotationLambda', {
  entry: join(__dirname, './custom-rotation/main.ts'),
  environment: {
    PARAMETER_NAME: secretParameter.parameterName,
  },
  runtime: Runtime.NODEJS_18_X,
});

secretParameter.grantRead(rotationLambda);
secretParameter.grantWrite(rotationLambda);

// Schedule the rotation every 5 minutes using a CloudWatch Event Rule.
new Rule(this, 'rotationRule', {
  schedule: Schedule.rate(Duration.minutes(5)),
  targets: [
    new LambdaFunction(rotationLambda),
  ],
});
```
*Source: <a href="https://github.com/cino/cdk-examples/blob/main/parameter-store-vs-secret/lib/parameter-store-secret-custom-rotation-stack.ts" target="_blank">parameter-store-secret-custom-rotation-stack.ts</a>*

Lambda:

```typescript
export const handler: ScheduledHandler = async (
  event: ScheduledEvent,
): Promise<void> => {
  const parameterName = process.env.PARAMETER_NAME as string;

  await ssmClient.send(new PutParameterCommand({
    Name: parameterName,
    Value: new Date().toISOString(),
    Overwrite: true,
  }));
}
```

This is however an extremely simplified version as this would only set the value to the latest date, in a real world example you could first generate an API key in a external service by calling an API and directly after that update the value in the Secure Parameter.

## Secret Rotation Example

In the case of AWS Secrets there is a specific feature that allows you to rotate the value of the secret, this is a very powerful feature that allows you to rotate the value of the secret without having to write any code. In the case of a custom secret you would need to write a custom lambda that would rotate the value of the secret, this is a lot more work than using the AWS Secrets Manager.

In the case of a custom secret I've created an example lambda that I've made available in a <a href="https://github.com/cino/typescript-lambda-examples/blob/main/src/secret-manager-rotation.ts" target="_blank">special repository</a> and will also show below, first of all setting this up via CDK is very easy.

```typescript
const customSecret = new Secret(this, 'customSecret', {
  secretName: '/parameter-store-vs-secret/secret-rotation-custom',
});

customSecret.addRotationSchedule('RotationSchedule', {
  rotationLambda: new NodejsFunction(this, 'rotationLambda', {
    entry: join(__dirname, './custom-rotation-secret/main.ts'),
    architecture: Architecture.ARM_64,
    runtime: Runtime.NODEJS_18_X,
    timeout: Duration.seconds(30),
  }),
  automaticallyAfter: Duration.days(1),
});
```

Instead of the need to create a seperate CloudWatch Event Rule and Lambda Function you can simply add the rotation schedule to the secret. This will automatically create the CloudWatch Event Rule and Lambda Function for you with the correct permissions to be able to retrieve/store the secret.

The lambda function will actually be a bit more complex than with the Parameter Store as there are 4 different events that you need to handle, these are:

- createSecret
  - This event is triggered at the start of the process where a new version of the secret will be created with a new value. This can either be generated or retrieved from a external service.
- setSecret
  - This event is triggered after the createSecret event and will be the phase where you would persist the secret value in a external service to be able to authenticate with it.
- testSecret
  - After setting the secret in the external service you will need to test if the secret is valid, this is done by calling the external service with the new secret value and see if the authentication is done properly. Additionally you can also include some extra authorization checks.
- finishSecret
  - The last and final step is where you would change the state of the new secret to 'AWSCURRENT' and remove the old version of the secret, only in this step, after the testing phase the new secret will be used.


```typescript
async function createSecret(
  arn: string,
  token: string,
): Promise<void> {
  // Check if the current version exists
  await secretsClient.send(
    new GetSecretValueCommand({
      SecretId: arn,
      VersionStage: 'AWSCURRENT',
    }),
  );

  try {
    // Check if the pending version exists otherwise create a new one
    await secretsClient.send(
      new GetSecretValueCommand({
        SecretId: arn,
        VersionStage: 'AWSPENDING',
      }),
    );

    console.log(`Secret version ${token} already exists for secret ${arn}`);
  } catch (exception) {
    /**
     * Here we would create a new secret / create a new API key in an external service and create a new secret version.
     *
     * For this demo purpose we are going to create a new secret version with a random string
     */

    const randomString = Math.random().toString(36).substring(2, 15) + Math.random().toString(36).substring(2, 15);

    // If the current version does not exist, create a new one
    await secretsClient.send(
      new PutSecretValueCommand({
        SecretId: arn,
        ClientRequestToken: token,
        SecretString: randomString,
        VersionStages: ['AWSPENDING'],
      }),
    );

    console.log(`Secret version ${token} created for secret ${arn}`);
  }
}

async function setSecret(): Promise<void> {
  /**
   *
   * Set the secret in the external application / service unless the token has been generated
   * by the previous step by using an api.
   *
   */
}

async function testSecret(): Promise<void> {
  /**
   *
   * Test if the secret is working and the correct permissions are set in the external application / service
   *
   */
}

async function finishSecret(
  arn: string,
  token: string,
): Promise<void> {
  const metaData = await secretsClient.send(
    new DescribeSecretCommand({
      SecretId: arn,
    }),
  );

  // Check if the current version is already set correctly and stop the process.
  let currentVersion: string | undefined = undefined;
  if (metaData.VersionIdsToStages) {
    for (const version in metaData.VersionIdsToStages) {
      if (metaData.VersionIdsToStages[version].includes('AWSCURRENT')) {
        if (version === token) {
          console.log(`Version ${version} is already set as AWSCURRENT for secret ${arn}`)
          return;
        }
        currentVersion = version;
        break;
      }
    }
  }

  // If not finialize the secret rotation process
  await secretsClient.send(
    new UpdateSecretVersionStageCommand({
      SecretId: arn,
      VersionStage: 'AWSCURRENT',
      MoveToVersionId: token,
      RemoveFromVersionId: currentVersion,
    }),
  );

  console.log('Secret rotation process finished');
}

export const handler: SecretsManagerRotationHandler = async (
  event: SecretsManagerRotationEvent,
): Promise<void> => {
  console.log(JSON.stringify(event));

  const arn = event.SecretId;
  const token = event.ClientRequestToken;
  const step = event.Step;

  const metadata = await secretsClient.send(
    new DescribeSecretCommand({
      SecretId: arn,
    }),
  );

  if (metadata.RotationEnabled !== true) {
    throw new Error(`Secret ${arn} is not enabled for rotation`);
  }

  const versions = metadata.VersionIdsToStages;
  if (versions) {
    if (token in versions === false) {
      throw new Error(`Secret version ${token} has no stage for rotation of secret ${arn}.`);
    }

    if (versions[token].includes('AWSCURRENT')) {
      throw new Error(`Secret version ${token} already set as AWSCURRENT for secret ${arn}.`);
    } else if (versions[token].includes('AWSPENDING') === false && step !== "createSecret") {
      throw new Error(`Secret version ${token} not set as AWSPENDING for rotation of secret ${arn}.`);
    }
  }

  switch (step) {
    case "createSecret":
      await createSecret(arn, token);
      break;
    case "setSecret":
      await setSecret();
      break;
    case "testSecret":
      await testSecret();
      break;
    case "finishSecret":
      await finishSecret(arn, token);
      break;
    default:
      throw new Error(`Unsupported step "${step}"`);
  }

  return;
}
```




## Pricing

Here we go, with AWS it's always about pricing. Especially since there is a <a href="https://docs.aws.amazon.com/wellarchitected/latest/cost-optimization-pillar/welcome.html" target="_blank">specific pillar</a> about it. So let's take a look at the pricing of both services.

<table>
  <tr>
    <td><strong>Service</strong></td>
    <td><strong>Count</strong></td>
    <td><strong>Requests</strong></td>
    <td><strong>Price</strong></td>
  </tr>
  <tr>
    <td>Parameter Store</td>
    <td>25</td>
    <td>10,000</td>
    <td>$0.00</td>
  </tr>
  <tr>
    <td>Secrets</td>
    <td>25</td>
    <td>10,000</td>
    <td>$10.05</td>
  </tr>
</table>

As you can see in the comparison calculated by <a href="https://calculator.aws" target="_blank">calculator.aws</a> the Parameter Store is a lot cheaper than the Secrets Manager. This is because the Secrets Manager is a lot more feature rich and has a lot more functionality than the Parameter Store. However, if you are not using the rotation feature of the Secrets Manager you are paying a lot more for the same functionality.
