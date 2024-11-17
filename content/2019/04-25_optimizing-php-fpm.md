+++
author = "Ricardo Cino"
title = "Optimizing PHP-FPM"
slug="optimizing-php-fpm"
date = "2019-04-25"
tags = [
    "php"
]
+++

As mentioned in the previous post about <a href="/2019/laravel-forge-setting-it-up-the-right-way/" target="_blank">laravel forge and setting it up the right way</a> there was going to be a separate post just about PHP-FPM and how to configure it correctly.
<!--more-->

## What is FPM?

PHP-FPM stands for “Fast Process Manager” and is mostly being used in combination with an Nginx webserver. If you look at the config of an Nginx webserver which is set up to be used with PHP-fpm you’ll find a proxy pass that points to the PHP-FPM socket, meaning that whenever a certain request lands in Nginx it will be sent towards the PHP-FPM socket.

## How to spot PHP-FPM problems

Spotting PHP-FPM problems on your server is actually quite easy since PHP will stop working, you’ll receive 5xx errors, and when looking into your PHP fpm log file /var/log/php7.4-fpm.log (Or change to the correct version, can also be located in another location depending on configuration but this should be the default) there are errors like:

{{< highlight bash >}}
```WARNING: [pool www] server reached pm.max_children setting (25), consider raising it```
{{< / highlight >}}

What this means is that you’ve reached the point where there are more nginx processes being sent towards the PHP-FPM socket than it’s able to handle. This is easily solved by looking critically at the configuration options within the PHP-fpm pool located at `/var/etc/php/7.4/fpm/pool.d/www.conf` (Once again, the file could be at another location. This is at an Ubuntu VM set up by Laravel Forge.)

## What are the configuration options?

FPM can be configured a whole lot more than we are going to discuss here, the options we are looking at are:

### pm

This is used to set how the process manager will control the number of child processes. There are 3 options you can choose out: static, dynamic and ondemand. These are all 3 valid options with different use cases:

**static**: A fixed number of child processes, this also means that there are always a fixed amount of processes that are reserving resources. This could be a good option if you have a very consistent amount of traffic.

**ondemand**: There will be zero processes spawned by default and will only be created once they are requested. After x amount of seconds, the process will be killed again. This does mean that because the process needs to be started again and again this will be the slowest option.

**dynamic**: The most common option and in most situations the best is dynamic, here it is possible to use the configuration options below and optimize it to start with a set amount of default processes and allow it to scale up when necessary

### pm.max_children

The number of child processes are created in static mode and also the amount of maximum simultaneous children that can be created while using the dynamic mode. It can be a bit confusing since with static these will be created instantly while for dynamic it is a limit.

### pm.start_servers

The number of child processes that will be created on startup when using dynamic mode.

### pm.min_spare_servers

This refers to the minimum amount of idle processes, which are necessary because this means once you have less than the minimum amount of spare processes new process will be created in advance. This will help out once you actually need that process because it’s already started.

### pm.max_spare_servers

Logically these are the maximum of spare processes, once the traffic goes down and there are more and more spare processes php-fpm will start killing them to free op server resources.
pm.max_requests

The number of requests a process can process before being killed and re-spawned, this can be very helpful if there is a memory leak somewhere in your application that you cannot solve yourself (Always, but always fix memory leaks). The default value of max_requests is set to 0 which means infinite, I’d suggest changing this to a number you are comfortable with, for example, 100.

## Calculating the optimal settings

For the max_children the option we need to make sure we are aware of how much memory each request is necessary, or at least an average per request. The reason behind this is that it’s not possible to run more simultaneous requests than the amount of memory combined is available on your server. Imagine having 4GB of ram and trying to run 100 processes with 128MB of memory consumption, this is doomed to fail so we can protect the server against it.

So the basic formula for the max_children is: `averageProcessMemory / $availableMemory`.

However, since we are not able to use all the memory of the server you’ll need to take some buffer into account. Luckily, Chris Moore created a simple calculator that can help us with the calculation.

<img src="/img/optimizing-php-fpm/spot13-pmcalculator.webp" alt="Spot13 PM Calculator">

So, as you can see we need to fill in 4 variables: Total Ram, Reserved Ram, Ram Buffer% & Process size. The first and last speak for themselves. The reserved ram is the amount of ram that is already in use by your server, for example when you are running a database on the same server that also relies on memory you like to make sure it can access it. The last variable is the RAM Buffer %, it is highly advised as well to have a percentage of RAM available because otherwise, you’re going to kill your server. It’s safer to have PHP-fpm kill some requests than the server being full of memory and stops responding.

## Example configuration

Just to make life easy I’ve added a small overview of how many processes can simultaneously be run on a server with 4GB of ram and different memory process sizes. You can see as the memory per process increases the amount of children decreases. This should help you realize to make sure you are aware of the process size on your server and optimize the process manager for maximum usage.

| Memory per process | 40MB | 64MB | 128MB | 256MB |
|---|---|---|---|---|
| pm.max_children | 69 | 43 | 21 | 10 |
| pm.start_servers | 17 | 10 | 5 | 2 |
| pm.min_spare_servers | 17 | 10 | 5 | 2 |
| pm.max_spare_servers  | 51 | 32 | 15 | 7 |

This example is for when you have a server with a maximum of 4GB of ram.
