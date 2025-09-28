+++
author = "Ricardo Cino"
title = "InvalidSignature in Node with AWS SDK"
slug = "invalidsignature-aws-sdk-nodejs"
date = 2025-09-28T18:01:00+01:00
tags = [
    "aws",
    "invalid signature",
    "invalid",
    "signature",
    "sdk",
    "secrets manager",
    "nodejs",
    "lambda",
]
images = []
+++

Sometimes you run into a weird issue that is hard to debug. This was one of those times. I was working on a Lambda function that was supposed to retrieve a secret from AWS Secrets Manager. However, I kept getting random `InvalidSignatureException` errors in production.

<!--more-->

## What is the issue?

The issue arose in our production environment, where the Lambda function would sometimes throw `InvalidSignatureException` errors when making calls to AWS services. This was perplexing because around 99% of the requests were successful, and the errors seemed to occur randomly.

### Root cause

After extensive debugging and investigation, I discovered that the root cause of the issue was related to how the AWS SDK client was being initialized in our codebase. We had implemented a Repository pattern, and in the constructor of the repository, we were initializing the AWS SDK client to retrieve secrets from AWS Secrets Manager.

However, we were initializing the repository outside of the Lambda handler function, which meant that the same instance of the AWS SDK client was being reused across multiple invocations of the Lambda function.

This is due to the fact that we stored the SDK client in a property of the repository class, which was instantiated only once when the Lambda function was cold-started. As a result, the client would retain the same timestamp for signing requests, leading to signature mismatches and subsequent `InvalidSignatureException` errors.

### Solution

While it's normally a good practice to initiate the repository outside of the handler, in this case, the solution was to move the initialization of the AWS SDK client inside the Lambda handler function. This ensures that a fresh client with a current timestamp is used for each invocation, preventing the `InvalidSignatureException` errors.

Imagine having a repository like this:

```typescript
export class MyRepository {
    private readonly client: Promise<PrismaClient>;

    constructor() {
        this.client = getClient();
    }
```

Where `getClient` retrieves the Client instance to interact with the database, and within this function we would retrieve the secrets from AWS Secrets Manager where an AWS SDK Client is initialized. When doing this all outside of the handler, we would always re-use the same instance of the AWS SDK client, that would retain the same timestamp for signing requests.

So going from this:

```typescript
import { MyRepository } from "./my-repository";

const repository = new MyRepository();

const handler = async (event) => {
  // implement
};
```

to this:

```typescript
import { MyRepository } from "./my-repository";

const handler = async (event) => {
  const repository = new MyRepository();

  // implement
};
```

### The downside

Because now the repository is initialized on every invocation, we lose the benefits of reusing the same instance across invocations, which causes us to retrieve the secrets from AWS Secrets Manager on every invocation. This can lead to increased latency and costs, especially if the Lambda function is invoked frequently.

However, we have implemented caching mechanisms within the repository to mitigate this issue. The repository caches the secrets after the first retrieval, so subsequent invocations can use the cached values instead of making repeated calls to AWS Secrets Manager.

This approach strikes a balance between ensuring valid signatures for AWS SDK requests and optimizing performance by reducing redundant calls to Secrets Manager.

An easy way to implement caching is to use <a href="https://docs.powertools.aws.dev/lambda/typescript/latest/features/parameters/#fetching-secrets" target="_blank">AWS Powertools Parameters utility</a>, which provides a simple way to cache parameters and secrets in memory and automatically refresh them after a specified duration. When not providing any additional configuration, it defaults to caching the secrets for 5 seconds:

```typescript
import { getSecret } from '@aws-lambda-powertools/parameters/secrets';

export const handler = async (): Promise<void> => {
  // Retrieve a single secret
  const secret = await getSecret('my-secret');
  console.log(secret);
};
```
(example from <a href="https://docs.powertools.aws.dev/lambda/typescript/latest/features/parameters/#fetching-secrets" target="_blank">AWS Powertools documentation</a>)

{{< article-footer >}}
