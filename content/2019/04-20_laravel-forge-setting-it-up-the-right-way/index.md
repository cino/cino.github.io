+++
author = "Ricardo Cino"
title = "Laravel Forge: setting it up the right way"
slug="laravel-forge-setting-it-up-the-right-way"
date = "2019-04-20"
tags = [
    "php"
]
+++

For the last couple of years, I’ve been creating servers with Laravel Forge and normally I would advise against doing this (In favor of running containers or other load balanced tasks), but for the sake of giving advice to those who do want to do it, this is the first post I’ll spend time on it.

For the record, I’ll be writing from an AWS perspective since this is the only provider I have extensive experience with on Laravel Forge but I’ll expect the others to work quite the same.

<!--more-->

## First things first

When you start to use Laravel Forge with AWS you’ll need to create an IAM user with the right amount of permissions to create and manage your servers. This should always be from the least access principle. The documentation of Laravel Forge suggests you’ll create a user with the policies `AmazonEC2FullAccess` and `AmazonVPCFullAccess`. However, this looks like a bit too much access in my opinion and my advice would be to initially grant access with these policies and closely monitor what features are actually necessary with the IAM Access Advisor.

When creating the Laravel Forge user you will need to enable programmatic access to provide Forge with an access key and secret. I’d like to point out that it is **recommended** to rotate these credentials every 90 days but I’ll suggest making a reminder for every **60 days**. *Personal preferences though*.

## Networking

This is actually something that annoys me quite a lot, when using a cloud provider for your servers it can be confusing to find out that you are using a double “firewall”. For example, in AWS we use the concept of security groups where you’ll define the ports which are open and for whom. When using Laravel Forge the server will also have UFW installed. These two different will have different ports open; on UFW only ports 22, 80, and 443 will be opened, which is correct. On the AWS Security Group it will look like this:

{{< image src="laravel-forge-ec2-security-group-example.webp" alt="Laravel Forge Security Group Exaple" >}}

Especially when you see inbound ports 0-65535 open it should warn you that something isn’t as it should be. AWS Security Advisors will also advise you to look at this because it is uncommon. My first step would be to modify this to allow SSH from the Laravel Forge servers (IPs are available in their <a href="https://forge.laravel.com/docs/1.0/introduction.html#forge-ip-addresses" target="_blank">documentation</a>), your own IP/bastion, and just HTTP/HTTPS for the web.

Whenever someone will try to access any other port on your domain it will be killed on network-level within AWS and will never even reach your server.

Another big reason for setting these rules on the security group is that your AWS Console actually shows you the active rules applied to your instance. It can be really confusing if you’re going through the console, seeing all the ports open and when trying to connect realizing there is a UFW active on the server level.

## Source Provider Credentials

Alright, this is one that bit me in the ass pretty hard. When you add a source provider like GitHub to your Laravel Forge account the default behavior is that Laravel Forge generates an SSH key on the server and adds this key to the Source Provider user on the account level. This means that this specific server can clone **any** repository that the user has access to.

As mentioned when providing Laravel Forge access to AWS we should provide access based on the least access principle, if you’re granting git access this way **you’re doing it wrong**. So please, disable the following checkbox when creating a server.

{{< image src="laravel-forge-ssh-key-source-control-providers.webp" alt="Laravel Forge SSH Key Source Control Providers" >}}

The correct way to go forward is when deploying a site on the newly created server instance is to create a deploy key in the repository you’d like the server to have access to.

This is also documented in the documentation of Laravel Forge but as the default behavior is the less-secure behavior I found it more than important to mention this.

Just to give you an example, imagine having 50+ servers managed by Laravel Forge and every single server has access to all of your GitHub repositories (when the user has access to your complete organization) and **one** of these servers is compromised, the source code of all your projects are compromised. This seems like a pretty big risk to me.

## PHP & Memory

The main usage of Laravel Forge is (as expected) for web development in PHP and thus PHP is configured when creating a server. However, when you look into the PHP configuration you’ll find that the memory_limit is set to 512MB which is crazy high for a normal web application. (WordPress defaults to 40 for example). My first step would be to lower this to 128MB or even 64MB if you are sure you don’t need more.

### PHP-FPM

I’m planning on writing an extensive post about php-fpm and the settings around `pm.max_children`, `pm.start_servers`, `pm.min_spare_servers` and `pm.max_spare_servers` for now, I’m going to keep it as simple as advising you to visit the <a href="https://spot13.com/pmcalculator/" target="_blank">calculator</a> made by <a href="https://spot13.com" target="_blank">Chris Moore</a>.

Make sure you enter the correct values in the calculator for the amount of memory your server has and the max memory consumption per request setup as memory_limit in the previously mentioned configuration.

Update: <a href="/2019/optimizing-php-fpm/" target="_blank">PHP FPM and Memory</a>

## Databases

You have the option to auto-create your Mysql database which will be fine in most cases. Nothing special on that part besides since we never explicitly opened the 3306 port to the public you’ll need to access the database with an SSH connection which is actually displayed on the database page these days!
That’s a wrap

This is about it for my main frustrations of the things I change immediately after setting up a new instance with Laravel Forge. There are many other Laravel Forge-related topics I’m going to rant write about as there are more small things that need adjustment.
