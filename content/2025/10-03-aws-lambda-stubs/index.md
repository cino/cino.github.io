+++
author = "Ricardo Cino"
title = "AWS Lambda Stubs for unit testing"
slug = "aws-lambda-stubs"
date = 2025-11-03T12:01:00+01:00
tags = [
"aws",
"lambda",
"stubs",
"unit testing",
"sdk",
"nodejs",
"typescript",
"package",
"npm"
]
images = []
+++

When working with AWS Lambda functions, unit testing can be a challenge due to the need to mocking all external dependencies, including AWS SDK clients. But also to provide the correct input when calling your Lambda handler functions. To make this easier, I created a small npm package that provides stubs for AWS Lambda handler functions, allowing you to easily provide a default event and customize the input with minimal changes.

<!--more-->

## Introducing aws-lambda-stubs

The <a href="https://www.npmjs.com/package/aws-lambda-stubs" target="_blank">aws-lambda-stubs</a> package provides a set of stubs for AWS Lambda handler functions, making it easier to unit test your Lambda functions by providing default events and allowing you to customize the input as needed making your tests cleaner and more maintainable.

A simple example provided by the README of the package looks like this:

```typescript
import { SQSEventStub } from "aws-lambda-stubs";
import { describe, expect, it } from "vitest";
import { handler } from "../src/sqs";

describe("sqs handler", () => {
  it("should log the received event", async () => {
    const mockEvent = SQSEventStub([
      {
        body: { message: "Hello, World!" },
      }
    ]);

    // assert on output
    expect(handler(mockEvent)).toEqual({});
  });
});
```
This clearly demonstrate how easy it is to create a mock SQS event with a custom message body. The output of above example would be a completely valid SQS event that you can pass to your Lambda handler function for testing looking like this:

```json
{
  "Records": [
    {
      "messageId": "1",
      "receiptHandle": "MessageReceiptHandle",
      "body": "{\"key\":\"value\"}",
      "attributes": {
        "ApproximateReceiveCount": "1",
        "SentTimestamp": "1523232000000",
        "SenderId": "123456789012",
        "ApproximateFirstReceiveTimestamp": "1523232000001"
      },
      "messageAttributes": {},
      "md5OfBody": "ea7e1632014d79bb59dd5e08c6aaea39",
      "eventSource": "aws:sqs",
      "eventSourceARN": "arn:aws:sqs:us-east-1:012345678901:queue-name",
      "awsRegion": "us-east-1"
    }
  ]
}
```

### Why did I build this?

After working on multiple projects, seeing numerous git repositories and seeing everyone making their own stubs for AWS Lambda events, or - non-reusing- stubs making unit tests much larger because of perparing empty test data, I decided to create a reusable package that can be used across multiple projects. This way, I can avoid duplicating code and make it easier for developers to write unit tests for their Lambda functions. Making this open source makes it available for everyone to use and contribute to.

### What is supported?

The <a href="https://www.npmjs.com/package/aws-lambda-stubs" target="_blank">aws-lambda-stubs</a> package aims to support all payloads given to AWS Lambda functions. Currently, it supports all the EventTypes provided by <a href="https://www.npmjs.com/package/@types/aws-lambda" target="_blank">@types/aws-lambda</a>.

## Important while using

What still is very important while making unit tests is that you always test on the input that you expect your Lambda function to receive. The stubs provided by this package are just a starting point, and you should always customize the input to match your specific use case. This way, you can ensure that your unit tests are accurate and reliable.

In the case the defaults change inside the package, your tests might break, so always make sure to check the input you provide to your Lambda handler functions to ensure that they match your expectations.

## Next steps

So while this package is already usable, there is still work to be done. My goal is to provide more and more stubs with valuable presets that can be used out of the box. If you want to contribute, please check the repository at <a href="https://github.com/cino/aws-lambda-stubs" target="_blank">https://github.com/cino/aws-lambda-stubs</a> as I would love to make this not just mine, but a community-driven project.

{{< article-footer >}}
