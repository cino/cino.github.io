+++
author = "Ricardo Cino"
title = "Limiting AWS Lambda's access to Log Groups"
slug = "limiting-aws-lambdas-access-to-log-groups"
date = "2022-05-11"
tags = [
    "aws",
    "serverless"
]
+++
About a year ago I asked the question on <a href="https://www.reddit.com/r/aws/comments/o3fbge/is_awslambdabasicexecutionrole_not_way_too_open/" target="_blank">Reddit</a> what people thought of the default Lambda role called "AWSLambdaBasicExecutionRole" and why I thought it was way too open to be a default.

To this day I  still think this role shouldn't be used at all, but rather be deleted by Amazon itself. While I agree that Amazon wants people to get started as quickly as possible it is not in line with the least access principle. For this reason, I always define the role myself, for starters only allowing the Lambda function to write to its own CloudWatch Log Group. There is no reason for the Lambda function to be able to write to log groups of other services rather than its own.
<!--more-->

Luckily it's quite simple to create a custom permission for the Lambda function using the CDK. We can simply create a custom role, assign the role without permissions to the Lambda function, then add the custom permission to the role allowing the correct permissions to write to the CloudWatchlog group. Why in this order? We need this order to retrieve the generated LogGroup location from the Lambda in the permission, if we wouldn't be using the AWS CDK we would've done this directly in the permission by assuming the correct name. Luckily this isn't necessary and this is future proof (and re-usable when you put it in a custom struct/generate it in a function).

As an example, I've created the smallest working CDK project which displays exactly how this can be realized below:

{{< highlight typescript >}}
// Create your custom IAM Role
const customRole = new Role(this, 'CustomRole', {
  roleName: 'CustomRole',
  assumedBy: new ServicePrincipal('lambda.amazonaws.com'),
});

// create smallest lambda function possible and assign the custom role.
const lambdaFunction = new NodejsFunction(this, 'Function', {
  entry: './dist/function.js',
  role: customRole,
});

// Create an inline policy which only allows the role to write logs to the log group
// that is automatically created by the lambda function.
customRole.attachInlinePolicy(
  new Policy(this, 'loggingPolicy', {
    statements: [
      new PolicyStatement({
        effect: Effect.ALLOW,
        actions: [
          'logs:CreateLogGroup',
        ],
        resources: ['*'],
      }),
      new PolicyStatement({
        effect: Effect.ALLOW,
        actions: [
          'logs:CreateLogStream',
          'logs:PutLogEvents',
        ],
        resources: [
          lambdaFunction.logGroup.logGroupArn,
        ],
      }),
    ],
  }),
);
{{< / highlight >}}

A full working example can be found in my Github repository containing this and future examples at <a href="https://github.com/cino/cdk-examples/tree/main/lambda-custom-role" target="_blank">this location</a>.
