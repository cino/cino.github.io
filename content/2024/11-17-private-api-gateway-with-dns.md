+++
author = "Ricardo Cino"
title = "Private API Gateway with DNS"
slug = "private-api-gateway-with-dns"
date = "2024-11-17"
tags = [
    "aws",
    "amazon web services",
    "api gateway",
    "networking",
    "vpc",
    "dns",
    "vpc endpoint",
    "private",
    "route 53",
    "application load balancer",
]

[meta]
description = "TEST"
+++

At PostNL we are building most of our applications with [Serverless](https://medium.com/postnl-engineering/business-overview-f7c8d8ebee2c) in mind, let me rephrase that, we build all our applications within our own landing zone with Serverless only. There is no option to deploy any kind of EC2 and if you need containers you'd be running them on Fargate only.

Given that, we are using quite a bunch of API Gateways in the projects I'm working on. While PostNL is also a big corporate company we have a strong focus on security and compliance, and that's why we are building our applications **Private first**. When there is no need to be public, it shouldn't be.

This is however, easier said then done when trying to do it with API Gateway and I'll show you why.

<!-- more-->

## API Gateway

To start, let's have a look at Amazon API Gateway. When you create a gateway you'll be provided with an endpoint that is public by default and hosted under the Amazon domain (*.execute-api.{region}.amazonaws.com). This is not what we want, we want to have our API Gateway private and only accessible from within our VPC.

For Public API Gateways you can use a custom domain name and use Route 53 to point to the API Gateway endpoint. This is not possible for Private API Gateways, you can't use a custom domain name and you can't use Route 53 to point to the API Gateway endpoint.

When you deploy a simple API Gateway without any custom dns your architecture would look as simple as:
<img src="/img/2024/private-api-gateway-with-dns/1-api-gateway-lambda.png" alt="API Gateway with Lambda">

Now when you'd like to add your own custom DNS on a public API Gateway you can do so by creating a custom domain name and using Route 53 to point to the API Gateway endpoint (you can leverage the custom domain feature on api gateway natively [here](https://docs.aws.amazon.com/apigateway/latest/developerguide/how-to-custom-domains.html)). This would look like:

<img src="/img/2024/private-api-gateway-with-dns/2-api-gateway-lambda-dns.png" alt="API Gateway with Lambda and Custom DNS">

At this point it still looks simple, but when you'd like to have a private API Gateway you can't use a custom domain name and you can't use Route 53 to point to the API Gateway endpoint. This is where it gets tricky.

## Why a custom domain?

Even though it's not supported for Private API's you might wonder why would you need a custom domain on your API Gateway. To me there is a simple reason why I want this. Within a larger organization on AWS you often have other teams / aws accounts invoke your api's.

When you are in a situation like this often you have 2 options:

- There is a central team that manages all the api's and they provide you with the endpoint to invoke the api. (which still means that you need to provide a private network connection to the central API team).
- You allow another team to invoke your api's by providing them with the endpoint of the api gateway.

When you don't have custom dns on your API Gateway the only option to provide the API to a different account is to provide them with the API Gateway ID, which they'll use together with a VPC Endpoint in their account to reach your API Gateway. This is not a very user-friendly way to provide an API to another team.

<img src="/img/2024/private-api-gateway-with-dns/3-api-gateway-lambda-private-dns-vpce.png" alt="API Gateway with Lambda and VPC Endpoint">

A downside of this is that you _lose_ the flexibility to replace or update the API Gateway without having to update all the consumers that are using the API Gateway. When you have a custom domain name you can point the domain to a new API Gateway and the consumers don't have to change anything.

When you have a custom domain name you can provide the other team with a domain name that they can use to invoke the API Gateway. This is a much more user-friendly way to provide an API to another team.

## The Problem

As noted before it is not possible to use a custom domain name on a private API Gateway. This means that you can't use Route 53 to point to the API Gateway endpoint. The actual technical reason for me is still unknown but I do know that the API Gateway is not deployed inside your own VPC.

The only way to reach the API Gateway is by using a VPC Endpoint. This is a private connection between your VPC and the API Gateway. This is a great way to provide a private connection to the API Gateway but it doesn't provide you with a way to reach the API Gateway via a custom domain name.

## The Solution

The solution to this problem is to use an Application Load Balancer (ALB) in front of the VPC Endpoint. You will need to retrieve the private ip addresses of the VPC Endpoint and point a target group towards these. The ALB is deployed in your VPC and is reachable via a custom domain name. This way you can reach the API Gateway via the custom domain name and fully private net working.

The beauty of this solution is that you can provide the custom domain name to other teams and they can invoke the API Gateway via the custom domain name without having to know the specifics of the API Gateway. Because the consumer is now not aware of what is behind the DNS you can replace it with whatever you want without having to update the consumers.

This is how the architecture would look like:

<img src="/img/2024/private-api-gateway-with-dns/4-api-gateway-lambda-private-dns-alb.png" alt="Private API Gateway with Lambda and Route53">

## CDK Example

It's not a post from me without a CDK example, so here it is. In this example we are creating an API Gateway with a simple Mock Integration Response that is reachable via private DNS. The API Gateway is deployed in a VPC and is only reachable when invoked via the VPC Endpoint, to be able to use private DNS we are deploying an Application Load Balancer which is pointed towards the VPC Endpoint. Based upon the domain name that is pointed towards the Application Load Balancer and that is configured on the API Gateway we can reach the API Gateway via the private DNS.

```typescript
const apiFqn = "api.cino.dev";

// Step 1: Retrieve vpc / hosted zones
const [vpc, publicHostedZone, privateHostedZone] = this.getNetwork();

// Step 2: Create API Gateway VPC Endpoint
const apiGatewayVpcEndpoint = this.createApiGatewayVpcEndpoint(vpc);

// Step 3: Create certificate for the API Gateway / ALB
const acmCertificate = this.createCertificate(apiFqn, publicHostedZone);

// Step 3: Create ALB
const alb = this.createApplicationLoadBalancer(vpc, apiGatewayVpcEndpoint);

// Step 4: Create API Gateway
this.createApiGateway(apiFqn, acmCertificate, apiGatewayVpcEndpoint);

// Step 5: Create ALB Listener for API Gateway VPC Endpoint
this.createApiGatewayVpcEndpointListener(
  acmCertificate,
  vpc,
  alb,
  apiGatewayVpcEndpoint
);

// Step 6 Create Route53 records pointing towards
// the Application Load Balancer
this.createDnsRecords(privateHostedZone, alb, apiFqn);
```

As you see we need the following resources:
- VPC
- Hosted Zones (Public & Private)
  - Public Hosted Zone is used for the certificate
  - Private Hosted Zone is used for the DNS records
- API Gateway VPC Endpoint
- Certificate for the API Gateway / ALB
- Application Load Balancer
  - Listener on port 443 for your domain pointing towards the VPC Endpoint Private IP Adresses
- API Gateway
- Custom Domain Name pointing towards the Application Load Balancer

For the full example you can visit the Github repository [here](https://github.com/cino/cdk-examples/blob/main/private-api-gateway-dns/lib/private-api-gateway-dns-stack.ts) as I'll only show you the most important parts of the code, that said we immediately go to step 5 where we create the API Gateway VPC Endpoint Listener.

```typescript
private createApiGatewayVpcEndpointListener(
  acmCertificate: Certificate,
  vpc: IVpc,
  alb: ApplicationLoadBalancer,
  apiGatewayVpcEndpoint: InterfaceVpcEndpoint
): void {
  const ipAddresses = this.getVpcEndpointIpAddresses(
    vpc,
    apiGatewayVpcEndpoint
  );

  const targets = ipAddresses.map((ip) => new IpTarget(ip));
  const apiGatewayTargetGroup = new ApplicationTargetGroup(
    this,
    `PrivateApiGatewayTargetGroup`,
    {
      vpc: vpc,
      targetType: TargetType.IP,
      targetGroupName: `priv-apigw-tg`,
      targets,
      protocol: ApplicationProtocol.HTTPS,
    }
  );

  apiGatewayTargetGroup.configureHealthCheck({
    path: `/test/hello`,
    healthyHttpCodes: "200,403",
    port: "443",
  });

  alb.addListener("PrivateApiGatewayListener", {
    port: 443,
    protocol: ApplicationProtocol.HTTPS,
    certificates: [acmCertificate],
    defaultTargetGroups: [apiGatewayTargetGroup],
  });
}

private getVpcEndpointIpAddresses(
  vpc: IVpc,
  vpcEndpoint: InterfaceVpcEndpoint
): string[] {
  const vpcEndpointProps = new AwsCustomResource(this, "VpcEndpointEnis", {
    onUpdate: {
      service: "EC2",
      action: "describeVpcEndpoints",
      parameters: {
        Filters: [
          {
            Name: "vpc-endpoint-id",
            Values: [vpcEndpoint.vpcEndpointId],
          },
        ],
      },
      physicalResourceId: PhysicalResourceId.of(Date.now().toString()),
    },
    policy: AwsCustomResourcePolicy.fromSdkCalls({
      resources: AwsCustomResourcePolicy.ANY_RESOURCE,
    }),
  });

  const vpcEndpointIps = new AwsCustomResource(
    this,
    "vpc-endpoint-ip-lookup",
    {
      onUpdate: {
        service: "EC2",
        action: "describeNetworkInterfaces",
        outputPaths: vpc.availabilityZones.map((_, index) => {
          return `NetworkInterfaces.${index}.PrivateIpAddress`;
        }),
        parameters: {
          NetworkInterfaceIds: vpc.availabilityZones.map((_, index) => {
            return vpcEndpointProps.getResponseField(
              `VpcEndpoints.0.NetworkInterfaceIds.${index}`
            );
          }),
        },
        physicalResourceId: PhysicalResourceId.of(Date.now().toString()),
      },
      policy: AwsCustomResourcePolicy.fromSdkCalls({
        resources: AwsCustomResourcePolicy.ANY_RESOURCE,
      }),
    }
  );

  return vpc.availabilityZones.map((_, index) => {
    return vpcEndpointIps.getResponseField(
      `NetworkInterfaces.${index}.PrivateIpAddress`
    );
  });
}
```

The important part about this piece of code is we are creating a listener towards the private ip addresses of the created VPC Endpoint. This is done by creating a target group with the private ip addresses and creating a listener on the Application Load Balancer that points towards the target group.

However, the private ip addresses of the VPC Endpoint are not directly available in the CDK, so we need to use a Custom Resource to retrieve the private ip addresses of the VPC Endpoint. This is done by creating a Custom Resource that retrieves the VPC Endpoint ID and then creates another Custom Resource that retrieves the private ip addresses of the VPC Endpoint.

Full example can be found [on GitHub](https://github.com/cino/cdk-examples/blob/main/private-api-gateway-dns/lib/private-api-gateway-dns-stack.ts).

## Conclusion

In this post I've shown you how you can create a private API Gateway with DNS. This is not a straightforward process and requires some additional resources to make it work. However, when you have a need for a private API Gateway with DNS this is the way to go.

Please have a good look at the Github link provided as there are a lot more details to be found and it is a fully working example with a simple `cdk deploy` command. (when you provide your own route53 / hosted zone)

I hope this post was helpful to you and if you have any questions or remarks feel free to reach out to me on [Bluesky](https://bsky.app/profile/cino.io) or [LinkedIn](https://www.linkedin.com/in/cinoricardo/).
