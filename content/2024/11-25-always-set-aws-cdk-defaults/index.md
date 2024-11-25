+++
author = "Ricardo Cino"
title = "Always set AWS CDK Defaults"
slug = "always-set-aws-cdk-defaults"
date = 2024-11-25
tags = [
  "aws",
  "amazon web services",
  "cdk",
  "cloudformation",
  "kinesis",
  "removal policy",
  "cost",
]
images = ['kinesis-removal-policy-change-cost.png']
+++

We are nearing the end of the year, the time to reflect on the past year and definitely share the things that went "wrong" or in this case the things that could have been done better. This is one of those things that I wish I knew earlier, and I hope it helps you too.

<!--more-->

## AWS CDK Defaults.. they change

As you're reading this you definitely know what AWS CDK is and you are most likely also using it. If you are not, I'd suggest you take a look at it, it's a great way to manage your AWS infrastructure in a programmatic way (nothing against the likes of Terraform and/or Pulumi, cdk is just my chosen evil (and mandated by the company)).

CDK is designed to be as user-friendly as possible, allowing you to create Amazon resources easily and quickly. To do so, it comes with a lot of defaults, which is great, but it can also be a bit risky.

Reason for me saying it are the following:

- I was not aware of the defaults, and I was not aware that the defaults of CDK are NOT the same as AWS CloudFormation

- Defaults change, and they can change without you knowing it

## What happened?

In the projects I work with we always have a full CI/CD setup with a lot of tests. For each pull-request we open we deploy a full environment with AWS CDK and run a lot of tests against it. This is great, and really helps us to catch a lot of issues before they hit production.

While deploying all the resource is great, we also need to destroy the resources that we created and this is where the issue started. Before a [certain change in CDK](https://github.com/aws/aws-cdk/pull/30037) the default RemovalPolicy for Kinesis Stream was set to `DESTROY`, which is great for testing but not so great for production. After the change the default was set to `RETAIN`, which I support as for production you would want this.

However, because we were not setting the RemovalPolicy ourselves, we were relying on the default. This meant that after the change we were not able to delete the Kinesis Stream anymore, because the default was changed.

What surprised me about the change is that it was in a very large [pull-request](https://github.com/aws/aws-cdk/pull/30037) where a lot of changes were made, and it was not mentioned in the release notes. This is not a critique, but it's just something to be aware of.

## How did I find out?

You don't want to hear this, but yes, through the Cost Explorer. While randomly checking our Dev environment where the pull-request environments are deployed to there was a surprise peak in Kinesis cost, not being sure why I started digging into the resources and found out that many Kinesis streams were still there after Pull-Requests were closed.

{{< image src="kinesis-removal-policy-change-cost.png" alt="Kinesis cost spike" >}}

## Learnings

For me this taught me to always override the defaults of CDK, even if they are the same as the AWS defaults. This way you are sure that you are in control of the resources you are creating and you are not relying on the defaults of CDK. Giving you no surprises when a sudden change happens.
