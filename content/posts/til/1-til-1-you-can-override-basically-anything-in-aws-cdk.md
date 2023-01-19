+++
author = "Ricardo Cino"
title = "TIL #1 - You can override basically anything in AWS CDK"
slug = "you-can-override-basically-anything-in-aws-cdk"
date = "2022-04-03"
tags = [
    "til"
]
+++
Unique as I am I decided to start writing short blog posts about recent discoveries that suddenly clicked inside my head. For the first one; I have been working a lot with AWS CDK recently and decided that I wanted to contribute back to the AWS-CDK source code.

<!--more-->
For this reason, I spent quite some time within the Issues section of the AWS-CDK <a href="https://github.com/aws/aws-cdk">Github Repository</a> and learned that a lot of feature requests are requests for adding a property to a construct that isn't supported yet, while these are actually supported in CloudFormation. Which would make them easy pull requests to work on.

This is where I first found a comment about using an <a href="https://docs.aws.amazon.com/cdk/v1/guide/cfn_layer.html">Escape Hatch</a>, which enables you to modify the underlying CloudFormation template while working with the CDK project.

I never really thought much about using an Escape Hatch as I never needed one, however as I said at the beginning of this post it suddenly "clicked" in my brain. Because the Escape Hatch enables you every feature that CloudFormation already has thus provides you always a way to accomplish your task.

While this feature exists, I would always suggest trying to improve the CDK with a feature request or a pull request to enable the feature you are missing.
