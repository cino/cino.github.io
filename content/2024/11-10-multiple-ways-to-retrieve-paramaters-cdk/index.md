+++
author = "Ricardo Cino"
title = "Multiple ways to retrieve SSM parameters in AWS CDK"
slug = "multiple-ways-to-retrieve-ssm-parameters-cdk"
date = "2024-11-10"
tags = [
    "aws",
    "amazon web services",
    "cloudformation",
    "ssm parameters",
    "aws cdk",
    "aws cloud development kit",
    "infrastructure as code",
    "iac",
]

+++

When working with AWS CDK and using SSM Parameters to store information in between stacks there are multiple ways to retrieve the value, with both advantages and disadvantages. In this post, I'll go over the different ways to retrieve SSM parameters in AWS CDK and when to use them.

<!--more-->

## StringParameter.fromStringParameterName

The first way to retrieve an SSM parameter is by using the `StringParameter.fromStringParameterName` method. This method takes the name of the parameter and returns a `StringParameter` object. This object has a `stringValue` property that contains the value of the parameter.

```typescript
const parameter = StringParameter.fromStringParameterName(this, 'Parameter', 'MyParameter');
const value = parameter.stringValue;
```

However the property is called stringValue it does in fact not return a string value directly, it will be a reference towards a CloudFormation parameter. This means that the value will be retrieved during the deployment of the stack and not during the synthesis phase. In most cases this is fine behavior but it can be a problem when you want to use the value in your code.

## StringParameter.valueFromLookup

The second way to retrieve an SSM parameter is by using the `StringParameter.valueFromLookup` method. This method takes the name of the parameter and returns the value of the parameter as a string.

```typescript
const value = StringParameter.valueFromLookup(this, 'MyParameter');
```

This method will retrieve the value of the parameter during the synthesis phase and will return the value as a string. This is useful when you want to use the value in your code, for example when you want to use the value in a condition or need to manipulate it before the CloudFormation template is generated.
