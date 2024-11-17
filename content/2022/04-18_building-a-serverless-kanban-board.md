+++
author = "Ricardo Cino"
title = "Building a Serverless Kanban Board"
slug = "building-a-serverless-kanban-board/"
date = "2022-04-18"
tags = [
    "aws",
    "serverless"
]
+++
**Update 18/01/2023: Let's assume this is not gonna happen anymore**

As the title suggests I'm planning on building a Serverless Kanban Board to improve my personal Typescript skills in both the front and back end. Furthermore, the whole project will be set up while using Amazon Web Services (of course 😉)

I thought it would be fun to build something for practice and also have some personal projects on my GitHub page that display the latest techniques I'm working with and as a bonus get some material I can write about on the website!

<!--more-->
## The plan

So how is this going the be built? For building the application I've set a couple of rules for myself:

1. Everything needs to be Serverless, with zero servers, and zero operating systems we need to manage.
2. Everything needs to be built with Infrastructure as Code
3. s cheap as possible
4. Stateless (Api driven)
5. Automatically tested

To explain every rule a bit more let's break it down. First of all, as the title already suggested everything needs to be serverless. That is the most important part of this exercise for me as this is a requirement at my current employer (all are, to be honest) and I really like to have more hands-on experience going forward.

Secondly, this is something that has been around for more than a few years; You really want to have reproducible deployments and can be sure that every deployment will result in the same result. This will be done by using the AWS CDK and all deployments to the AWS Account will be automated with a Github Action while using the OIDC Connection.

Thirdly, this is quite simple. I am deploying this to my personal AWS account and I really like to keep it as cheap as possible to reduce any costs at my end. I will be publishing a report later to display how much this has cost me in the last periods over probably a time span of months. As serverless is mostly billed on usage level and usage will be very low I'm planning on staying in the Free tier as much as possible.

Stateless, this is an absolute necessity when building scalable applications. As we are building a serverless application it also means we have no infrastructure where we can temporarily store our data on a disk/memory as this will all be destroyed after the request. So this means that anytime we like to keep data, we will need to use a Serverless service like Amazon S3 for example.

And last but not least we are going to automatically test everything we set up, from the infrastructure with CDK to the code we write for AWS Lambdas in Typescript. This is a hard requirement for any project in the developer world in my personal opinion. Some tests may not be there in the beginning but we will definitely keep track of everything that has to be tested or even try some TDD (Test Driven Development) in there as well.

## The design

As every good project starts it starts with a high-level overview of how we are planning to set up the infrastructure, and of course, this has been done with <a href="https://draw.io">draw.io</a>

This is most definitely the first sketch and I will keep modifying this if I find myself making a mistake in the future, which is almost a guarantee.

<img src="/img/building-a-serverless-kanban-board/Serverless-Kanban.drawio-1.png" alt="Serverless Kanban Architecture">

This is the basic setup of how we are going to set this up, and this should be quite easy to understand.

We are going to create 2 different subdomains where the application is going to live, the front-end application at kanban.cino.io and the back-end API at kanban-api.cino.io where we will require Cognito Authorization before allowing the user to execute any API requests. Behind the API Gateway, we have multiple AWS Lambda functions (1 for every endpoint we need to keep the function as small as possible) which can all communicate with our database Amazon DynamoDB and every function is able to send an email by Amazon SES. As an extra Serverless feature, I'd like to play around with DynamoDB streams to automate certain actions as I've never used this service before. For example, we can automatically send an email to users that are following a certain kanban ticket when the status has changed because DynamoDB can trigger an event when data changes on the record.

The front-end is a lot smaller at the moment, that will host the application in an S3 Bucket and keep the static assets in another S3 Bucket, both of these will be served to the internet by the same CloudFront instance as we can use multiple origins and specify the path, this will mean that we cannot use the path "assets" in our application itself.

## Going forward

From now on I will be working on this side-project quite often and keep writing blogs about it. As the first few steps I'm going to set up a decent Github Project to keep up with all the tasks I'm going to work on, setting up the actual Live environment, might add a test environment but as this is a fun side-project I guess that ain't gonna happen :).

Besides setting up all these necessities the first actual problem that I'll need to face which is new for me is: Adding Cognito authentication to a React app in a secure way!
