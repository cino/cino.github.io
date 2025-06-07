+++
author = "Ricardo Cino"
title = "Private AppSync with custom dns"
slug = "private-AppSync-with-custom-dns"
date = 2025-06-06T18:00:00+01:00
tags = [
    "aws",
    "amazon web services",
    "AppSync",
    "networking",
    "vpc",
    "dns",
    "vpc endpoint",
    "private",
    "route 53",
    "application load balancer",
    "containers",
    "nginx",
    "proxy"
  ]
images = ['final-architecture.png']
+++

In the last year I've been working a **lot** with AppSync and I have to say it didn't come without challenges. One of the biggest challenges was to create a private AppSync API with a custom domain. This is something that is not natively supported by AWS, but it is possible to achieve it using a combination of services.

While this is now possible for API Gateway, AppSync is a different beast. There is no native way to create a private AppSync API with a private custom domain. This is something that I had to figure out the hard way, and I want to share my findings with you.

This might become a bit of a long read, but if you are looking for a way to create a private AppSync API with a custom domain, you are in the right place. I will try to explain the steps I took to achieve this and the challenges I faced along the way.

<!--more-->

# What is AppSync?

AppSync is a fully managed service that makes it easy for developers to build scalable Graphql APIs on AWS. It allows you to create a flexible API for applications that require real-time data, such as mobile or web apps. With GraphQL support, AppSync helps you to define the structure of your data and how it can be queried.

With AppSync, you can easily connect to various data sources, including DynamoDB, Lambda, Elasticsearch, and more. It also provides built-in support for real-time subscriptions, offline data synchronization, and security features like authentication and authorization.

While there are other challenges with Authorization, which I will not cover in this article (but _surely_ in a follow-up), I will focus on how to create a private AppSync API with a custom domain and all the challenges that come with it.

# Target Architecture

{{< image src="target-architecture.png" alt="Target Architecture" >}}
_(spoiler: We will **not** reach this architecture)_

This would be the ideal situation i'd like to see, however this is not possible with the current state of AppSync, with the main reason being that it's currently not possible to add a custom domain to a private AppSync API. Which results in that when you do try to point

# Private AppSync API

## Making it private

Making AWS AppSync private itself is not a big deal, you just need to toggle the `Use private API features` option in the AppSync console. This will allow you to create a private AppSync API that is only accessible from within your VPC. This is done by creating a VPC endpoint for AppSync, which allows you to access the service without going through the public internet.

> **Disclaimer 1**: You can not make a public AppSync API private, this needs to be configured at the start. This is a limitation of AppSync itself and not something that can be changed later on.

> **Disclaimer 2**: When you make an AppSync API private, you will not be able to access it from the aws console and losing the ability to use the console to test your API. This can be overcome by using the <a href="/2024/aws-cloudshell-in-your-own-vpc/" target="_blank" alt="AWS CloudShell in your own vpc">CloudShell</a> from your vpc or by deploying an EC2 instance inside your vpc.

## Private AppSync API with custom domain

Now this is the part where it becomes challenging, because AppSync does not support private APIs with custom domains. This means that you will not be able to use the default AppSync endpoint, which is something that you will have to work around by using additional services.

## Why a custom domain again?

While you could use the default AppSync endpoint, this is not recommended for production use. In case of a service replacement, you will have to update all your clients with the new endpoint. This is not a big deal if you are using a single client, but if you are using multiple clients (e.g. mobile and web), this can become a nightmare.

Even if you'd decide to switch to hosting your own GraphQL server you might be able to switch the back-end and not inform the client, if you keep supporting the exact same features as you are using. If you are using Subscriptions from AppSync it might become more challenging due to the implementation of AWS AppSync's authorization mechanism.

## Creating custom DNS for your AppSync API

To make your AppSync API accessible from a custom domain, you will have to use the same approach as you would for <a href="/2024/private-api-gateway-with-dns/" target="_blank">API Gateway before they introduced native support</a> . This means that you will have to create a Route 53 hosted zone for your custom domain and create a CNAME record that points to an Application Load Balancer that routes traffic to the AppSync VPC Endpoint.

However this is not enough, because where this will allow you to access the AppSync API from your custom domain, it will not allow you to *only* use the custom domain. Additionally you will have to send an HTTP header (X-AppSync-Domain) to the AppSync API that contains the custom domain name so the VPC Endpoint can route the traffic to the correct AppSync API. In that case you still need to share the AppSync API endpoint with the end user.

While it is technically possible to add the header to all your requests, this will only work for HTTP requests. If you are using WebSockets for subscriptions, you will not be able to add the header to the request, because the WebSocket protocol does not support custom headers in the web browser. When using a different client (e.g. mobile or server-side) you might be able to add the header, but this is not a solution that works for all clients.

The only way to avoid this limitation is to use a proxy that will route the traffic to the AppSync API. This can be done by using an Application Load Balancer with a custom domain and a target group that points a proxy (e.g. NGINX) that will route the traffic to the AppSync API. This way you can use the custom domain to access the AppSync API without exposing the AppSync API endpoint to the end user.

> **Disclaimer 3**: Whenever you use a custom private domain the default libraries provided (AppSync SDK & Amplify Framework's AppSync, see <a href="https://github.com/aws-amplify/amplify-data/issues/469" target="_blank">this issue</a> (especially the comment of `sleepwithcoffee` too.)) by AWS will not work. This is because the libraries are using the default AppSync endpoint and not the custom domain. This means that you will have to use a custom implementation of the AppSync client that supports custom domains.

To implement such proxy you can use NGINX, which is a popular web server that can be used as a reverse proxy. NGINX can be configured to route traffic to the AppSync API and add the required HTTP header (X-AppSync-Domain) to the request.

### Example

```
  location /graphql {
    proxy_set_header X-AppSync-Domain ${identifier}.appsync-api.eu-west-1.amazonaws.com;
    proxy_pass https://${url};
    proxy_pass_request_headers on;
    proxy_ssl_session_reuse off;
    proxy_cache_bypass $http_upgrade;
    proxy_redirect off;
    ...
  }

  location /graphql/ws {
    proxy_set_header X-AppSync-Domain ${identifier}.appsync-realtime-api.eu-west-1.amazonaws.com;
    proxy_pass https://${url};
    proxy_pass_request_headers on;
    proxy_ssl_session_reuse off;
    proxy_cache_bypass $http_upgrade;
    proxy_redirect off;
    ...
  }
```

## Final architecture

If we want to invoke our AppSync API from our custom DNS only the architecture will look like this:

{{< image src="final-architecture.png" alt="Final Architecture" >}}

Why is that? Well, the only way to access an AppSync API privately from your VPC is to use a VPC endpoint. This means that you will have to create a VPC endpoint for AppSync and route traffic from your custom domain to the VPC endpoint. This is done by creating an Application Load Balancer with the desired Custom DNS. Behind the ALB you will have 2 target groups, one for the AppSync VPC endpoint Private IP address to directly access the AppSync API and another one for the proxy that will be used to access the AppSync API from the browser.

With this setup, you can access the AppSync API from your custom domain without exposing the AppSync API endpoint to the end user. The proxy will handle the routing of the traffic to the AppSync API and will add the required HTTP header (X-AppSync-Domain) to the request.

# Wishes

Like API Gateway, AppSync is a service that is constantly evolving. I hope that in the future we will have a native way to create private AppSync APIs with custom domains. This would make our lives a lot easier and would eliminate the need for workarounds like the one I described in this article.

# Sources

- AWS Enterprise Support
- <a href="https://docs.aws.amazon.com/AppSync/latest/devguide/using-private-apis.html" target="_blank">https://docs.aws.amazon.com/AppSync/latest/devguide/using-private-apis.html</a>
- <a href="https://docs.aws.amazon.com/AppSync/latest/devguide/real-time-websocket-client.html" target="_blank">https://docs.aws.amazon.com/AppSync/latest/devguide/real-time-websocket-client.html</a>
- <a href="https://github.com/aws-amplify/amplify-data/issues/469#issuecomment-2578784043" target="_blank">https://github.com/aws-amplify/amplify-data/issues/469#issuecomment-2578784043</a>

I hope this post was helpful to you and if you have any questions or remarks feel free to reach out to me on <a href="https://bsky.app/profile/cino.io" target="_blank">Bluesky</a> or <a href="https://www.linkedin.com/in/cinoricardo/" target="_blank">LinkedIn</a>.
