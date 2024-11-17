+++
author = "Ricardo Cino"
title = "Avoiding CloudFormation Stack Outputs"
slug = "avoid-cloudformation-stack-outputs"
date = "2024-11-11"
tags = [
    "aws",
    "amazon web services",
    "cloudformation",
    "stacks",
    "outputs",
    "ssm parameters",
    "aws cdk",
    "aws cloud development kit",
    "infrastructure as code",
    "iac",
]
+++

Recently I've been working on a new project where we created many resources in a lot of different stacks. A feature of CloudFormation is that you can output values from your stack, which is great for referencing resources in other stacks. However, while there is a use-case for this, I've found that it's better to avoid using these outputs and instead use SSM parameters.

<!--more-->

## Why avoid outputs?

There is a simple reason for me to avoid using outputs and that is **dependencies**. When you output a value and import it an a different stack you create a hard dependency between the two stacks. This means that you can't delete the stack that is being referenced without first deleting the stack that is referencing it.

Even better, you can't remove the stack output without first deleting the stack that is referencing it. This is a problem when you want to remove a resource from a stack, even when you are updating multiple stacks at the same time it will fail because of the dependency, in many cases it will try to update the stack which has the resource which is used for output first before the second stack where it is referenced. Even when the second stack wouldn't need the output anymore in that same deploy it will still cause a reference issue due to the order of the updates.

This is good right? Well, yes. There is an absolute case to be made where this gives you safety and stops you from deleting resources that are still in use. However, in my case:

- We are deploying stacks often while making test environments and we want to be able to remove resources without having to delete all the stacks that are referencing it all-the-time.
- When you actually have an issue in production, dealing with stack dependencies is not something you want to be doing at that time.
- Destroying all your stacks can take a long time as they need to be deleted in the correct order.

## Surprise outputs by AWS CDK

If you are using AWS CDK for your infrastructure as code you might be surprised by the many outputs that you are using! This is because when you reference a Construct in another stack it will automatically output the identifier of the resource. This is a nice feature but it can also be a surprise when you are not expecting it. Even though you might be thinking that you are not using outputs, you are.

For example when you deploy the following stacks, in this example we are deploying 2 resources in different stacks, there is a DynamoDB table in the DataStack and a single Lambda function in the AppStack. The Lambda function has been given the permissions to read the DynamoDB table by passing it into the next stack and calling `table.grantReadData(lambda)`.
```typescript
const { table } = new DataStack(app, "DataStack");
new AppStack(app, "AppStack", { table });
```
_Full example: [example-with-stack-outputs.ts](https://github.com/cino/cdk-examples/blob/main/avoid-cloudformation-outputs/lib/stacks/example-with-stack-outputs.ts)_

When building your infrastructure in this way you will see that the CDK will automatically output the identifier of the DynamoDB table in CloudFormation.

{{< image src="datastack-output.png" alt="CloudFormation stack output example" >}}

This value is imported by the AppStack during the synthesize phase and used to retrieve the DynamoDB Table. Now you have a hard dependency between the two stacks. When we now try to delete the AppStack we will get the following error:

```typescript
const { table } = new DataStack(app, "DataStack");
// new AppStack(app, "AppStack", { table });
```

> Delete canceled. Cannot delete export DataStack:ExportsOutputFnGetAttDataStackTableB5A722F5ArnBE341008 as it is in use by AppStack.

You'll see that it now automatically tries to delete the created Output as it is not longer in use by the AppStack, however because CDK now doesn't have a notion of the AppStack it will only try to perform an update on the DataStack which will fail because the AppStack is still referencing it.

This is just a small example of how you can get into trouble with outputs without even knowing it.

## How to avoid this?

A pattern to avoid this is to store identifiers in SSM parameters. This way you can reference the SSM parameter in your other stacks and you can delete the resource without having to delete the stack that is referencing it. This does mean that when you delete the resource you will have to make sure that your other stacks don't depend on it anymore, giving you more risk of deleting resources that are still in use.

Personally for me this risk is worth it as you can still create dependencies between stacks during deployment like the example below. This way you are ensured that the resources are created in the correct order without having CloudFormation outputs and hard dependencies.

```typescript
const dataStack = new DataStackWithSsmParameters(app, "DataStackWithSsmParameters");
const appStack = new AppStackWithSsmParameters(app, "AppStackWithSsmParameters");
appStack.addDependency(dataStack);
```
_Full example: [example-with-ssm-parameters.ts](https://github.com/cino/cdk-examples/blob/main/avoid-cloudformation-outputs/lib/stacks/example-with-ssm-parameters.ts)_

## Conclusion

If you are using CloudFormation (or CDK) you can avoid finding yourself in a situation where you can't update a stack because of a reference to another stack by using SSM parameters instead of outputs. This way you can delete resources without having to delete the stacks that are referencing them.

In all the projects I'm working on myself I will not be using any outputs anymore and will be using SSM parameters instead. I've been hurt too many times with the hard dependencies between stacks and the time it takes to delete all the stacks in the correct order.

At 1 of the projects I had to delete 10+ stacks which would take more than 1 hour in a pipeline due to the dependencies between the stacks. Removing these outputs and importing the values from SSM Parameters decreased the time to delete all the stacks to ~20 minutes. I admit this is still a long time but this is because there was a CloudFront and Fargate container in the codebase. (Cloudfront being the longest to delete)

| ✅ Pros 	| ❌ Cons 	|
|---	|---	|
| Less conflicts when updating your stacks 	| Less "safety" out of the box from CloudFormation 	|
| Faster deletion of all your stacks in test environments 	| Needing to place dependencies between stacks yourself 	|
