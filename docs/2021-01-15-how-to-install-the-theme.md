---
author: ricardo
title: 'How To Install'
tags: jekyll ruby bundler documentation
---

<figure class="aligncenter">
	<img src="http://joro.me/demo-assets/jekyll/henry/arrival.webp" width="800" height="300" alt="Arrival" />
</figure>

I assume that you have already downloaded and installed Ruby. Here's what you need to do next:

1. Run <code>gem install jekyll bundler</code>.
2. Extract the theme to a desired folder.
3. Go into that folder by executing <code>cd name-of-the-folder</code>.
4. Run <code>bundle install</code>.
5. If you want to access and customize the theme, use <code>bundle exec jekyll serve</code>. This way it will be accessible on <code>http://localhost:4000/</code> or <code>http://127.0.0.1:4000/</code>. Also, after every change you make the theme will rebuild itself automatically.
6. Run <code>bundle exec jekyll build</code> and upload the content of the compiled <code>\_site</code> folder on your host server.
