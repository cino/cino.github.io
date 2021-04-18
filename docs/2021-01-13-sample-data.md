---
author: ricardo
title: 'Sample Data'
tags: jekyll demo documentation
---

<figure class="aligncenter">
	<img src="http://joro.me/demo-assets/jekyll/henry/1917.webp" width="800" height="400" alt="1917" />
</figure>

Markdown (or Textile), Liquid, HTML & CSS go in. Static sites come out ready for deployment.

**Headings**

# Heading 1

## Heading 2

### Heading 3

#### Heading 4

##### Heading 5

###### Heading 6

<!--more-->

**Blockquote**

> No more databases, comment moderation, or pesky updates to install—just your content.

**Unordered List**

-   Jekyll
    -   Nested Jekyll
    -   Nested Ruby
-   Ruby
-   Markdown
-   Liquid

**Ordered List**

1. Jekyll
    1. Nested Jekyll
    2. Nested Ruby
2. Ruby
3. Markdown
4. Liquid

**Link**

This is <a href="http://example.com/" title="Title">an example</a> inline link.

**Paragraph w/ strong, em, etc.**

These are just a few of the _available_ **configuration** options. Many configuration options can <strike>either</strike> be specified as flags on the <abbr title="Command Line Tool">command line</abbr>, or alternatively (and more commonly) they can be specified in a \_config.yml file at the root of the source directory. Jekyll will <a href="http://joro.me/" target="_blank">automatically use</a> the options from this file when run. For example, if you place the following lines in your \_config.yml file.

**Image**

<figure class="aligncenter">
	<img src="http://joro.me/demo-assets/jekyll/henry/dunkirk.webp" alt="Dunkirk" />
	<figcaption>From the movie <a href="https://en.wikipedia.org/wiki/Dunkirk_(2017_film)" target="_blank">Dunkirk</a>.</figcaption>
</figure>

**Video**

<div class="iframe-wrapper">
    <iframe width="560" height="315" src="https://www.youtube.com/embed/iWowJBRMtpc" frameborder="0" allowfullscreen></iframe>
</div>

**Default Code Tag**

I'm <code>code</code> block.

**Styled Code Block**

{% highlight ruby linenos %}
#!/usr/bin/ruby
$LOAD_PATH << '.'
require "support"

class Decade
include Week
no_of_yrs=10
def no_of_months
puts Week::FIRST_DAY
number=10\*12
puts number
end
end
d1=Decade.new
puts Week::FIRST_DAY
Week.weeks_in_month
Week.weeks_in_year
d1.no_of_months
{% endhighlight %}

**Definition Lists**

<dl>
    <dt>Definition Title</dt>
    <dd>Definition Description</dd>
</dl>

**Paragraphs w/ Aligned Images**

The Jekyll gem makes a jekyll executable available to you in your Terminal window. You can use this command in a number of ways.

<figure class="alignleft">
	<img width="250" src="http://joro.me/demo-assets/jekyll/henry/joker.webp" alt="Joker" />
	<figcaption>From the movie <a href="https://en.wikipedia.org/wiki/Joker_(2019_film)" target="_blank">Joker</a>.</figcaption>
</figure>

This site aims to be a comprehensive guide to Jekyll. We’ll cover topics such as getting your site up and running, creating and managing your content, customizing the way your site works and looks, deploying to various environments, and give you some advice on participating in the future development of Jekyll itself.

Jekyll is a simple, blog-aware, static site generator. It takes a template directory containing raw text files in various formats, runs it through a converter (like Markdown) and our Liquid renderer, and spits out a complete, ready-to-publish static website suitable for serving with your favorite web server. Jekyll also happens to be the engine behind GitHub Pages, which means you can use Jekyll to host your project’s page, blog, or website from GitHub's servers for free.

<figure class="alignright">
	<img width="250" src="http://joro.me/demo-assets/jekyll/henry/fightclub.webp" alt="Fight Club" />
	<figcaption>From the movie <a href="https://en.wikipedia.org/wiki/Fight_Club" target="_blank">Fight Club</a>.</figcaption>
</figure>

Throughout this guide there are a number of small-but-handy pieces of information that can make using Jekyll easier, more interesting, and less hazardous. Here's what to look out for.

If you come across anything along the way that we haven’t covered, or if you know of a tip you think others would find handy, please file an issue and we’ll see about including it in this guide.

The front matter is where Jekyll starts to get really cool. Any file that contains a YAML front matter block will be processed by Jekyll as a special file. The front matter must be the first thing in the file and must take the form of valid YAML set between triple-dashed lines.
