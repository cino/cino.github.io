+++
author = "Ricardo Cino"
title = "DynamoDB Streams with more than 24 hour retention"
slug = "dynamodb-streams-with-more-than-24-hour-retention"
date = 2025-06-24T19:00:00+01:00
tags = [
    "aws",
    "amazon web services",
    "dynamodb",
    "kinesis",
    "retention",
    "streams",
]
images = ['dynamodb-24-hour-retention.png']
+++

That was kind of a misleading title, but I wanted to get your attention. The truth is that DynamoDB Streams have a maximum retention period of 24 hours and there is no way to extend that. When you do need more than 24 hours the default solution is to use Kinesis Data Streams, which can retain data for up to <a href="https://docs.aws.amazon.com/streams/latest/dev/kinesis-extended-retention.html">365 days</a>. While it would be easy to just move to Kinesis, this comes with extra cost which may not be justified for all use cases.

<!--more-->

## Why not Kinesis?

At the time of writing this I actually am using Kinesis Data Streams for a project, but the only reason we are using it is because we need to retain data for more than 24 hours in case of a failure in the processing lambda. At the time this was built time was of the essence, and we needed a solution that would work out of the box. Kinesis Data Streams is a fully managed service that integrates well with Lambda, and it was the quickest way to get started.

Time has passed and since we now have more time to think about the architecture, we are now considering alternatives to Kinesis Data Streams. The main reason is that Kinesis Data Streams is more expensive than DynamoDB Streams, and we are not using all the features that Kinesis provides. We only need to retain data for a few days, and we can achieve that with DynamoDB Streams by using a custom solution.

This in combination with a workflow where for every pull-request we spin up a new environment this will increase the cost drastically and when you don't necessarily need the performance of Kinesis Data Streams, you can save a lot of money by using DynamoDB Streams instead.

### DynamoDb Streams Vs Kinesis Data Streams

DynamoDB Streams and Kinesis Data Streams are both services that allow you to process data in real-time, but they have
different use cases and features. Here are some key differences while using DynamoDB stream:

- **Retention Period**: DynamoDB Streams have a maximum retention period of 24 hours, while Kinesis Data Streams can retain data for up to 365 days.

- **Cost**: DynamoDB Streams are generally cheaper than Kinesis Data Streams, especially for small workloads. Kinesis Data Streams can become expensive as the number of shards increases, while DynamoDB Streams are priced based on the number of read requests.

## The custom solution

{{< image src="dynamodb-24-hour-retention.png" alt="DynamoDB 24 Hour Retention Architecture" >}}

This might look a bit odd with 2 queues but there is a logical reason for it, the first queue is there because when you put an `onFailure` destination on a DynamoDB Stream handler it will not place the DynamoDB Record change in the queue, but rather an object with the *location in the stream* of the record change. This means that if you try to process the message after 24 hours, it will not contain the actual data of the record change, but rather just the data on where to extract it. This message will look like:

```json
{
  "requestContext": {
    "requestId": "12a8a0fa-f8d2-4d42-a6e3-72bae7d1e2f9",
    "functionArn": "arn:aws:lambda:<region>:<account>:function:stream-handler",
    "condition": "RetryAttemptsExhausted",
    "approximateInvokeCount": 4
  },
  "responseContext": {
    "statusCode": 200,
    "executedVersion": "$LATEST",
    "functionError": "Unhandled"
  },
  "version": "1.0",
  "timestamp": "2025-06-05T18:22:26.479Z",
  "DDBStreamBatchInfo": {
    "shardId": "shardId-10101010101010101010-10101010",
    "startSequenceNumber": "202328600001712385967261751",
    "endSequenceNumber": "202328600001712385967261751",
    "approximateArrivalOfFirstRecord": "2025-06-05T18:21:49Z",
    "approximateArrivalOfLastRecord": "2025-06-05T18:21:49Z",
    "batchSize": 1,
    "streamArn": "arn:aws:dynamodb:<region>:<account>:table/table/stream/2025-04-23T13:37:16.991"
  }
}
```

As you can imagine, if you would process this message after 24 hours it would not be very useful as the data at this location in the DynamoDB Stream would have been deleted. This is why we are using a second queue, the first queue is used to retrieve the actual data from the DynamoDB Stream, and the second queue is used to store the data for a longer period of time. In my case, I am using SQS as the second queue, which is not enabled by default, but you can enable it in the Lambda function configuration. This way, you can process the data from the first queue and store it in the second queue for later processing.

Whenever there is a real failure of our DynamoDB Stream handler it will give us some time to investigate the issue and resolve it before we enable the re-drive lambda and process the messages in the second queue. This way, we can ensure that we are not losing any data and that we can process it later when we have time to investigate the issue.

## Idempotency

When you are using a solution like this you do want to make sure that your processing is idempotent. This means that if you process the same message multiple times, it will not have any side effects. In our case, we have used <a href="https://docs.powertools.aws.dev/lambda/typescript/latest/utilities/idempotency/" target="_blank">AWS Lambda Powertools for TypeScript</a> (also available, with more features for other languages; <a href="https://docs.powertools.aws.dev/lambda/python/latest/" target="_blank">Python</a>, <a href="https://docs.powertools.aws.dev/lambda/dotnet/" target="_blank">.NET</a> and <a href="https://docs.powertools.aws.dev/lambda/java/latest/" target="_blank">Java</a>) to implement idempotency in our DynamoDB Stream handler in the critical points where we do not want to reprocess the same step unless it failed there. I can highly recommend using this library as it provides a lot of useful utilities for working with AWS Lambda, including idempotency, logging, and tracing.

## Conclusion

Obviously this is not a standard solution, but it's a cost-effective way to retain data for more than 24 hours without using Kinesis Data Streams. It does require some extra work to set up, but it can save you money in the long run if you don't need the full capabilities of Kinesis. If you do need more than 24 hours of retention, Kinesis Data Streams is still a great option, but if you can work with the limitations of DynamoDB Streams, this custom solution can be a good alternative.

{{< article-footer >}}
