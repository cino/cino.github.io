+++
author = "Ricardo Cino"
title = "Testing in a serverless environment"
slug = "testing-in-serverless-environment"
date = 2025-08-22T15:01:00+01:00
tags = [
    "aws",
    "serverless",
    "testing",
    "github",
    "github actions",
    "deployment",
    "unit testing",
    "integration testing",
    "infra testing",
    "self-hosted-runners",
]
images = []
+++

Working in a pure serverless environment presents a distinct set of challenges when testing your software, particularly when multiple services interact with each other. In this post, I will explore some strategies for testing in a serverless environment.

<!--more-->

## Types of testing

When it comes to testing, there are different types of tests that you can implement in your software development lifecycle. Here are some of the most common types of tests:

- **Unit tests**: These tests focus on individual components or functions of your codebase, ensuring that each part works as intended in isolation.
- **Integration tests**: These tests evaluate how different components of your application work together, verifying that they interact correctly and produce the expected results.
- **Infrastructure tests**: Tests to confirm that the infrastructure outputs the expected results and behaves as intended.
- **End-to-end tests**: These tests simulate real user scenarios, testing the entire application stack from the frontend to the backend, including all external dependencies.

What we are going to focus on is primarily **integration tests**, which verify the interactions between different services in a serverless architecture.

### Unit testing

Before we continue to integration tests it's important to mention that in my current environment **everything** is unit tested and we aim towards a high 90% test coverage on our codebase, obviously test coverage is not the end goal and you should properly think about what you are testing.

The reason we focus so much on unit testing is that these are the cheapest and fastest tests to execute. We test every path of our code with unit tests to ensure the results are as we expect them. We do this in the unit test to ensure we can build many tests, and run them locally fast while still building the integration tests to make sure they run in the cloud.

### Integration testing

The fun part, how do you properly test your serverless application and why is it so important? The challenge with serverless is that, besides having your own codebase, there are many different parts of infrastructure that you need to consider, such as API gateways, lambdas, databases, queues, you name it. When you have all these different parts working together, there is one thing that unit tests will really not cover: the authorization between these components.

- Can your lambda reach the database?
- Does it have permissions to access the database?
- Do you have the correct IAM Permission to send messages to SQS?

**So how do we test this?**

To make sure we can safely test our serverless application, we can do a number of things; You can use a tool like [LocalStack](https://www.localstack.cloud/), which I haven't done before but surely am looking at for a next adventure. Or, you can spin up a full environment for your change request and execute tests against your new environment.

![diagram](steps.png)

What we like to do in our project is, on each pull request, we deploy a completely new environment prefixed with `pr-{pr-number}`. This does take a while to complete, based on all the resources that you'll be deploying, but it will be worth your while.

Once this is done, we start tests, which will:

- Directly invoke our API's and expect a specific response. This will prove that the lambda behind our api can execute what is necessary and that the API Gateway is configured correctly.
- Push messages directly into queues or event buses, and we'll wait until a result has appeared in a database or S3 bucket.

This gives us great confidence that the software that we deploy can be executed with the right permissions and configuration in place.

In comparison to the unit tests, in the integration tests, we do not test all paths, as these have been covered by the unit tests. What we do test is making sure that each external service (database/queue/other service needing specific configuration) is working as expected. In some cases, that is a single test; if there is a non-default path where a message goes to a specific queue or database, there will be a second test, and so on.

## Infrastructure tests

A part from testing your code, you also want to make sure that your infrastructure is creating the resources as you expect. As such, you should include tests that validate the infrastructure itself. This can include checking that the correct number of resources have been created, that they are configured correctly, and that they have the right permissions (I know, this sounds double compared to integration tests, but think of it as layers of tests).

When working with AWS CDK you can do this in multiple manners, for one you can use [Snapshot tests](https://docs.aws.amazon.com/cdk/v2/guide/testing.html#testing-snapshot) which capture the current state of your infrastructure and compare it to a state you previously stored inside the repository, this is useful for quick assertions on IF anything has changed and forces you to update the snapshot when you do.

Or you can use my favourite; [fine-grained assertions](https://docs.aws.amazon.com/cdk/v2/guide/testing.html#testing-fine-grained), with this you can specifically check if the output of your CDK App matches your expectations. For example if the Lambda environment has a correct reference to a SSM Parameter, or if the Lambda function has the correct memory configured that is required to execute correctly.

## Private testing

If you are a frequent reader of my blog, it must come as no surprise that I am a big advocate for building private architecture when you can. This, however, will give you an additional challenge if you are deploying all your resources in a private network and trying to run an end-to-end test in your CI/CD pipeline.

When working with GitHub Actions, for example, in a default workflow, your tests will be running in a GitHub runner, which would not have any access to your private network. To overcome this limitation, you can use [self-hosted](https://docs.github.com/en/actions/concepts/runners/self-hosted-runners) runners that are deployed within your private network. In our company, this is provided out-of-the-box by the Cloud Center of Excellence, and there is a [great article](https://medium.com/postnl-engineering/building-scalable-ci-cd-pipelines-with-self-hosted-github-actions-on-amazon-codebuild-6a82150a3eb2) about it written by a colleague at PostNL and fellow AWS Community Builder [Matheus das Mercês](https://awsbythebook.com/).

## Conclusion

As you can see, testing your software in a serverless environment can be challenging, but with the right strategies and tools, you can ensure that your application is working as expected. By implementing a combination of unit tests, integration tests, infrastructure tests, and end-to-end tests, you can build a robust testing strategy that will help you catch issues early and ensure that your application is reliable and scalable.

{{< article-footer >}}
