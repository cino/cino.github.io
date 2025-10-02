+++
author = "Ricardo Cino"
title = "Modifying DynamoDB TTL with CDK"
slug = "modifying-dynamodb-ttl-with-cdk"
date = 2025-03-22T12:00:40+01:00
tags = [
    "aws",
    "amazon web services",
    "dynamodb",
    "ttl",
    "time to live",
    "cdk",
    "error",
    "ValidationException",
    "UpdateTimeToLive",
    "InvalidRequest",
    "errors"
]
images = []
+++

Ever tried to update the TTL attribute of a DynamoDB table using the AWS CDK and got a `InvalidRequest` in CDK or a `ValidationException` via the CLI? I did, and it took me a while to figure out why. In this post, I'll explain what happened and how to avoid the same issue in the future. This is a short post, but I think it's worth sharing because it can save you some time and frustration.

<!--more-->

## Introduction

Very recently I spent a few hours trying to figure out why I was getting a `ValidationException` when trying to update the TTL attribute of a DynamoDB table using the AWS CDK. The error message was not very helpful, and I couldn't find any documentation that explained the issue. After some digging (and asking around on Slack), I discovered that the problem was related to the fact that the TTL attribute was already set to a different value, and I was trying to change it to a new one which is not allowed in a single deployment.

## Modifying DynamoDB TTL with CDK

### The Error(s)

When you try to update the TTL attribute of a DynamoDB table using the AWS CDK, you might encounter the following error:

> Invalid request provided: Cannot change time-to-live attribute name. To update this property, you must first disable TTL then enable TTL with the new attribute name.

For me this was a surprise and wasn't aware this limitation existed. Followed by this error I thought, let me try this by the CLI and see if I can update it manually before deploying the CDK Stack. So to clear up; I was trying to disable the TTL by CLI and than re-run the stack with the new TTL attribute.

Of course that didn't work either, because the state of the CloudFormation stack was still in the previous state. So when validating the stack it would still throw the same exact error.

Next up I thought, let's try to disable the TTL via the CLI and then re-enable it with the new attribute name. This is where I got the following error:

> An error occurred (ValidationException) when calling the UpdateTimeToLive operation: Time to live has been modified multiple times within a fixed interval

### Why was I confused

To me this was a experience of surprises. I looked at the documentation and it didn't mention anything about this limitation. I thought I could just change the TTL attribute name and be done with it. This was mainly due to the DynamoDB CloudFormation documentation about the `TimeToLiveSpecification` property, which doesn't mention anything about this limitation. It actually mentions you can modify this property without any interruption on <a href="https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-resource-dynamodb-table.html#cfn-dynamodb-table-timetolivespecification" target="_blank">this page</a>.

And yes, there is a note below that saying there are limitations on DynamoDb and links to a new page, which does *not* mention the `TimeToLiveSpecification` property.

Now the second error I got was even more confusing. I was trying to disable the TTL and then re-enable it with a new attribute name, but I got an error saying that the TTL had been modified multiple times within a fixed interval. Again, this was something I hadn't yet spotted in any of the documentation which was a error on my side. I opened the documentation for <a href="https://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_UpdateTimeToLive.html" target="_blank">UpdateTimeToLive</A> and immediately scrolled down to the `Errors` section and this did not include the `ValidationException`.

However, at the top of the page that discusses the `UpdateTimeToLive` operation, it clearly states that:

> TimeToLiveSpecification. It can take up to one hour for the change to fully process. Any additional UpdateTimeToLive calls for the same table during this one hour duration result in a ValidationException.

So, if you try to disable the TTL and then re-enable it with a new attribute name within that one hour duration, you'll get the `ValidationException` error.

## Conclusion

In conclusion if you use any kind of Infrastructure as code tool, like the AWS CDK, you need to be aware of this limitation when modifying the TTL attribute of a DynamoDB table. You can't just change the attribute name and expect it to work. You'll need to:

1. Disable the TTL
2. Deploy the change
3. Wait for the change to be applied (up to one hour)
4. Enable the TTL with the new attribute name
5. Deploy the change
6. Wait for the change to be applied (up to one hour)

In hindsight, yes I could've spotted this in the documentation but I clearly didn't and as a result I lost multiple hours on researching but also, deploying.. and waiting for the changes to be applied. So I hope this post helps you avoid the same issue in the future.

### Sources
- <a href="https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/TTL.html" target="_blank">docs.aws.amazon.com/amazondynamodb/latest/developerguide/TTL.html</a>
- <a href="https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-resource-dynamodb-table.html#cfn-dynamodb-table-timetolivespecification" target="_blank">docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-resource-dynamodb-table.html#cfn-dynamodb-table-timetolivespecification</a>
- <a href="https://awscli.amazonaws.com/v2/documentation/api/latest/reference/dynamodb/update-time-to-live.html" target="_blank">awscli.amazonaws.com/v2/documentation/api/latest/reference/dynamodb/update-time-to-live.html</a>

{{< article-footer >}}
