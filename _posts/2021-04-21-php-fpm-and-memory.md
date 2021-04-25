---
author: ricardo
title: 'Optimizing PHP-PFM '
description: 'How to use and optimize php-fpm to support more workload'
tags: servers php-fpm php
disclaimer: true
---

As mentioned in the previous post about [laravel forge and setting it up the right way]({% post_url 2021-04-20-laravel-forge-setting-it-up-the-right-way %}) there was going to be a separate post just about PHP-FPM and how to configure it correctly.


<!--more-->

## What is FPM?

PHP-FPM stands for "Fast Process Manager" and is mostly being used in combination with a Nginx webserver. If you look at the config of a Nginx webserver which is set up to be used with php-fpm you'll find a proxy pass which points to the PHP-FPM socket, meaning that whenever a certain request lands in Nginx it will be sent towards the PHP-FPM socket.

## How to spot PHP-FPM problems

Spotting PHP-FPM problems on your server is actually quite easy since php will stop working, you'll receive 5xx errors and when looking into your php fpm log file `/var/log/php7.4-fpm.log` (Or change to correct version, can also be located in another location depending on configuration but this should be the default) there are errors like:

{% highlight text %}
WARNING: [pool www] server reached pm.max_children setting (25), consider raising it
{% endhighlight %}

What this means is that you've reached the point where there are more nginx processes being sent towards the PHP-FPM socket than it's able to handle. This is easily solved by looking critically on the configuration options within the php-fpm pool located at `/var/etc/php/7.4/fpm/pool.d/www.conf` (Once again, the file could be at another location. This is at an Ubuntu VM setup by Laravel Forge.)

## What are the configuration options?

FPM can be configured a whole lot more than we are going to discuss here, the options we are looking at are:
### pm
This is used to set how the process manager will control the number of child processes. There are 3 options you can choose out: `static`, `dynamic` and `ondemand`. These are all 3 valid options with different use cases:

**static**: A fixed number of child processes, this also means that there are always a fixed amount of processes which are reserving resources. This could be a good option if you have a very consistent amount of traffic.

**ondemand**: There will be zero processes spawned by default and will only be created once they are requested. After x amount of seconds the process will be killed again. This does mean that because the process needs to be started again and again this will be slowest option.

**dynamic**: The most common option and in most situations the best is `dynamic`, here it is possible to use the configuration options below and optimize it to start with a set amount of default processes and allow it to scale up when necessary

### pm.max_children
The number of child process are created in `static` mode and also the amount of maximum simultaneous children that can be created while using the `dynamic` mode. It can be a bit confusing since with `static` these will be created instantly while for `dynamic` it is a limit.

### pm.start_servers
The amount of child processes that will be created on start up when using `dynamic` mode.

### pm.min_spare_servers
This refers to the minimum amount of idle processes, which are necessary because this means once you have less than the minimum amount of spare processes new process will be created in advance. This will help out once you actually need that process because it's already started.

### pm.max_spare_servers
Logically these are the maximum of spare processes, once the traffic goes down and there are more and more spare processes php-fpm will start killing them to free op server resources.

### pm.max_requests
The amount of requests a process can process before being killed and re-spawned, this can be very helpful if there is a memory leak somewhere in your application which you cannot solve yourself (Always, but always fix memory leaks). The default value of max_requests is set to 0 which means infinite, I'd suggest changing this to a number you are comfortable with, for example 100.

## Calculating the optimal settings

For the `max_children` option we need to make sure we are aware of how much memory each request is necessary, or at least an average per request. The reason behind this is that it's not possible to run more simultaneously requests than the amount of memory combined is available on your server. Imagine having 4GB of ram and trying to run 100 processes with 128MB of memory consumption, this is doomed to fail so we can protect the server against it.

So the basic formula for the max_children is:
``$averageProcessMemory / $availableMemory. ``

However, since we are not able to use all the memory of the server you'll need to take some buffer in account. Luckily, <a href="https://spot13.com/" target="_blank" rel="noreferrer">Chris Moore</a> created a simple <a href="https://spot13.com/pmcalculator/" target="_blank" rel="noreferrer">calculator</a> that can help us with the calculation.

<figure class="aligncenter content-image">
    <a href="{{ "/assets/images/2021/04/spot13-pmcalculator.webp" | absolute_url }}" ref="lightbox">
        <img
            src="{{ "/assets/images/2021/04/spot13-pmcalculator.webp" | absolute_url }}"
            alt="Screenshot of Spot13 PMCalculator"
        />
    </a>
</figure>

So, as you cane see we need to fill in 4 variables: `Total Ram`, `Reserved Ram`, `Ram Buffer%` & `Process size`.
The first and last speak for itself. The reserved ram is the amount of ram that is already in use by your server, for example when you are running a database on the same server that also relies on memory you like to make sure it can access it. The last variable is the `RAM Buffer %`, it is highly advises as well to have a percentage of RAM available because otherwise you're going to kill your server. It's safer to have php-fpm kill some requests than the server being full of memory and stops responding.

## Example configuration

Just to make life easy I've added a small overview of how much processes can simultaneously be run on a server with 4GB of ram and different memory process sizes. You can see as the memory per process increases the amount of children decreases. This should help you realise to make sure you are aware of the process size on your server and optimize the process manager for maximum usage.

<table>
<colgroup>
<col width="50%" />
<col width="12.5%" />
<col width="12.5%" />
<col width="12.5%" />
<col width="12.5%" />
</colgroup>
<tbody>
<tr>
<td markdown="span">**Memory per process**</td>
<td markdown="span">**40MB**</td>
<td markdown="span">**64MB**</td>
<td markdown="span">**128MB**</td>
<td markdown="span">**256MB**</td>
</tr>
<tr>
<td markdown="span">**pm.max_children**</td>
<td>69</td>
<td>43</td>
<td>21</td>
<td>10</td>
</tr>
<tr>
<td markdown="span">**pm.start_servers**</td>
<td>17</td>
<td>10</td>
<td>5</td>
<td>2</td>
</tr>
<tr>
<td markdown="span">**pm.min_spare_servers**</td>
<td>17</td>
<td>10</td>
<td>5</td>
<td>2</td>
</tr>
<tr>
<td markdown="span">**pm.max_spare_servers**</td>
<td>51</td>
<td>32</td>
<td>15</td>
<td>7</td>
</tr>
</tbody>
</table>

_This example is for when you have a server with a maximum of 4GB of ram._
