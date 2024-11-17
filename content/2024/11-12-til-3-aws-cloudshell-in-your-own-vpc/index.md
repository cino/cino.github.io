+++
author = "Ricardo Cino"
title = "TIL #3 - AWS CloudShell in your own vpc"
slug = "aws-cloudshell-in-your-own-vpc"
date = "2024-11-12"
tags = [
    "aws",
    "amazon web services",
    "cloudshell",
    "networking",
    "vpc"
]
+++

Until recently, I was completely unaware of [AWS CloudShell](https://aws.amazon.com/cloudshell/), and I'm glad I finally decided to give it a try. CloudShell provides a shell environment right in your browser, and to my surprise, you can start an instance within your own VPC!

<!--more-->

## CloudShell in your own VPC

Why is this so cool? Well, I was working on a new example to show on my website I needed to access my private resources. While I have a full setup on my day-time job where I have a VPN connection to my VPC, I don't have this setup at my sandbox account. I was thinking about how I could access my private resources and then I remembered CloudShell.

When you start CloudShell you can select the VPC and subnet you want to use. This means that you can access your private resources without having to setup a VPN connection. This is great for me as I can now access my private resources without having to setup a VPN connection.

### Cost

I was a bit worried about the cost of running an CloudShell instance in my VPC, but it turns out that it's free! You can run an instance in your VPC for free and will be terminated after 30 minutes of inactivity.

## My use case

The real thing I was trying to do is resolve my Private DNS entries, by creating a Cloud Shell in my own VPC which was associated with the Private Hosted Zone I was able to resolve the Private DNS entries. This is great as I can now test my DNS entries without having to setup a VPN connection.

{{< image src="cloudshell-traceroute.png" alt="CloudShell example with traceroute to private dns record" >}}

_traceroute was not actually installed, you need to do that yourself ;)_
