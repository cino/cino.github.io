+++
author = "Ricardo Cino"
title = "Using AWS VPC Endpoints"
slug = "using-vpc-endpoints"
date = 2025-03-14T12:00:40+01:00
tags = [
    "aws",
    "amazon web services",
    "vpc",
    "vpc endpoint",
    "private networking",
  ]
images = []
+++

After posting about Private API Gateway's with DNS I received the suggestion by [Lee Gilmore](https://www.linkedin.com/in/lee-james-gilmore/) to elaborate on VPC Endpoints. In this article, I will show you how to use VPC Endpoints to access AWS services without the need to go through the internet.

<!--more-->

## What are VPC Endpoints?

If we take a step back and think about how we access AWS Services, we will see that most of the time we do it through the internet. This means that our VPCs need to have a route to the internet, which is not always ideal. For example, if we have a private subnet, we don't want to have a route to the internet if all we do is talk to Amazon Services.

## Types of VPC Endpoints

Amazon recently introduced two new types of VPC Endpoints: Resources and Service networks, however we are going to focus on the existing types which are Interface Endpoints and Gateway Endpoints.

### Gateway Endpoints

Gateway Endpoints are used to connect to S3 and DynamoDB. They are used to connect to services that are not in the VPC. This means that if you have a private subnet and you want to access S3, you can use a Gateway Endpoint to do so without the need to go through the internet.

Good to know about Gateway Endpoints:
- Free of charge
- Exclusively for S3 and DynamoDB
- Associated at the VPC Level
- Only has an endpoint policy

As these are free there should be no reason why you are not using them if you have a private subnet and need to access S3 or DynamoDB.

### Interface Endpoints
Interface Endpoints are used to connect to other AWS services like SNS, SQS, and [others](https://docs.aws.amazon.com/vpc/latest/privatelink/aws-services-privatelink-support.html).

Good to know about Interface Endpoints:
- Charged per hour (~8.03 USD per month in eu-west-1, based on 1 AZ, meaning if you use more than one AZ the cost will be higher)
- Charged per data processed (~0.01 USD per GB in eu-west-1)
- Uses Private IP Addresses
- Associated at the Subnet Level
- Has both a security group and a endpoint policy


## How do they work?

When a VPC Endpoint is created, AWS creates an ENI (Elastic Network Interface) in your VPC. This ENI is assigned a private IP address from the IP range of your subnet. This means that when you access the service, you are using a private IP address to do so. This is why you need to associate the VPC Endpoint with a subnet, as the ENI is created in that subnet.

### How does it route?

When you create a VPC Gateway Endpoint, you will need to update the route table of VPC to point to the Gateway Endpoint. This means that when you try to access S3 or DynamoDB, the traffic is routed to the Gateway Endpoint instead of the internet.

When you create a VPC Interface Endpoint in AWS, a DNS entry is automatically generated for the service you intend to access. This allows you to access the service using the endpoint's DNS name. For example, you might use `⁠vpce-{identifier}.execute-api.eu-west-1.vpce.amazonaws.com`. In addition to the regional DNS entry, AWS also creates Availability Zone-specific DNS entries. This means that if you have a private subnet in the eu-west-1a Availability Zone, the DNS entry will point to the Elastic Network Interface (ENI) created in that specific zone.

For example when you create a VPC Endpoint for API Gateway, you will get a DNS entry like this you will be able to execute your API Gateway using the following URL:

```bash
https://{rest-api-id}-{vpce-id}.execute-api.{region}.amazonaws.com/{stage}
```

This means that you can access the API Gateway without going through the internet. This is particularly useful if you have a private subnet and you want to access the API Gateway without going through the internet.

#### Additional sources
- [What are VPC endpoints?](https://docs.aws.amazon.com/vpc/latest/userguide/endpoint-services-overview.html)
- [API Gateway Private API Test Invoke URL](https://docs.aws.amazon.com/apigateway/latest/developerguide/apigateway-private-api-test-invoke-url.html)
