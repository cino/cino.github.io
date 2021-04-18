---
author: ricardo
title: 'How To Use'
tags: jekyll settings
---

<figure class="aligncenter">
	<img src="http://joro.me/demo-assets/jekyll/henry/matrix.webp" width="800" height="300" alt="The Matrix" />
</figure>

### Configuration

All configuration options are in the <code>\_config.yml</code> file. Let's take a look of the important ones.

#### General

-   **title**: Site name.
-   **description**: Site description.

#### Paths

These options are pretty important, so take a closer look. If you experience any problems with your paths you should check here.

-   **url**: A lot of people have problems when they try to setup their paths. That's why I've decided to keep things as simple as possible. So, usually you'll have to paste here your domain <code>https://mysite.com</code> and then in the baseurl you paste your subdomain (if there is one). The theme is configured to use absolute paths, so you'll have to paste the whole path here — domain + subdomain. For example, if your website is in the root folder, write down <code>https://mysite.com</code>, if there is a subfolder — <code>https://mysite.com/subfolder</code>. In this case you don't need the baseurl anymore.
-   **baseurl**: No longer needed due theme configuration. I left it just in case.

#### Options

-   **darkMode**: Enable/disable dark theme for the theme. If enabled you'll see an icon in the upper right corner.
-   **showTags**: Enable/disable visibility of post's tags.
-   **showCategories**: Enable/disable visibility of post's categories.
-   **showSearch**: Enable/disable visibility of global site search.
-   **showSharePost**: Enable/disable visibility of post's share options.
-   **showFavIcon**: Enable/disable visibility of favicon.
-   **showComments**: Enable/disable visibility of post's comments.
-   **showCookieBanner**: Enable/disable visibility of the cookie banner. This theme supports Google Analytics (GA), so there have to be some kind of user notification. If you don't use GA or other tracking service, you should disable it. Keep in mind that the banner is pretty basic, so in some cases you may need to customize it or entirely replace it with another third-party cookie service.
-   **useExternalContactForm**: Enable/disable usage of [Formspree](https://formspree.io/){:target="\_blank"} as default contact form. If this option is disabled, when you click **Contact** link in the main menu you'll be redirected directly to your default mail client. If enabled, a modal box will pop up and you'll be introduced to a more user-friendly contact form.
-   **useAnalytics**: Enable/disable usage of Google Analytics.

#### Third Party / Social

-   **facebook**: Link to your facebook page.
-   **twitter**: Link to your twitter page.
-   **instagram**: Link to your instagram page.
-   **email**: Your email address.
-   **formspree**: Link to your [Formspree](https://formspree.io/){:target="\_blank"} form. If you use Formspree, generate form ID and paste it here. Works only if you activated <code>useExternalContactForm</code> option in the previos section.
-   **googleAnalyticsTrackingCode**: Add your Google Analytics Tracking ID. Example ID: _UA-XXXXXXX-2_.
-   **disqusID**: Add your website shortname from Disqus. Keep in mind that by default Disqus comments are not configured. If you use this make sure <code>showComments</code> option is set to **true**.
-   **twitterHandle**: Add your Twitter handle.

<!--more-->

#### Permalinks

There is a default structure of your links. If you want a different one, please check [Jekyll documentation](https://jekyllrb.com/docs/permalinks/){:target="\_blank"}.

#### Pagination

-   **paginate**: Number of posts per page.
-   **paginate_path**: The default path is <code>/blog/page:num/</code>, so for example if you go to the second page you'll see something like this <code>http://mysite.com/blog/page2/</code>.

**Important Note:** Due to theme's compatibility with GitHub Pages, pagination is only supported on the default posts/blog page — **Blog**. When you list categories or tags, there is no pagination.

#### Includes

-   **include**: Force the inclusion of the <code>pages</code> directory.

#### Post Separator

-   **excerpt_separator**: By default when you're writing a post, you should add <code>&lt;!--more--&gt;</code> to define the end of the excerpt. If you remove this option your excerpt will show with the default settings and you'll not have control over the content. If you want to keep the custom separator (I strongly suggest) you can leave it as is or change the <code>&lt;!--more--&gt;</code> tag as well.

#### Assets Settings

-   **sass_dir**: Choose the path to your SCSS files.
-   **style**: Choose the compression method for the final CSS file.

If you need extra help, just check out the [official Jekyll documentation](https://jekyllrb.com/docs/home/){:target="\_blank"}.

### How To Add a Post

All you need to do is to add a file to your <code>\_posts</code> directory with the following format: <code>YEAR-MONTH-DAY-title.MARKUP</code>. Where YEAR is a four-digit number, MONTH and DAY are both two-digit numbers, and MARKUP is the file extension representing the format used in the file. You can overwrite these in the post's front matter. Take for example the current file. The title is different from the one in the filename.

In the beginning of the every post you have a so called [front matter](https://jekyllrb.com/docs/frontmatter/){:target="\_blank"} block which contains some data about the post. Here is the short description of the options.

-   **layout**: Post's layout. This setting is configured by default. Use only if you want a custom post layout.
-   **author**: Post's author. You can see all authors in the <code>authors.yml</code> file in the <code>\_data</code> folder.
-   **title**: Post's title. Overwrites the one from the filename.
-   **date**: Post's date. Overwrites the one from the filename.
-   **categories**: This post can be included under one or many categories. List them here. Keep in mind that you have to create a file for every new category. Check out the guide for creating a new category below.
-   **tags**: List the specific post tags. Keep in mind that you have to create a file for every new tag. Check out the guide for creating a new category below.
-   **description**: Meta description used for better SEO.
-   **comments**: By default they are always <code>true</code>, but if you want to turn them off for a specific post just set this to <code>false</code>.

You can add more or different data in the front matter by yourself. You'll just have to learn how to display it :).

### How To Add a Page

Adding page is even simpler than adding post. Go go <code>\_pages</code> folder and add a file with the following format: <code>page-title.FORMAT</code>. FORMAT is the file extension and it can be <code>.md</code>, <code>.markdown</code> or <code>.html</code>. Pages are also using front matter to add information to your page. Just like posts, pages have default front matter.

-   **layout**: The page's layout. Unlike posts, setting the layout for the page is required.
-   **title**: Page's title.
-   **permalink**: This is important. If you do not enter the permalink, your URL will be something like this <code>http://example.com/_pages/about</code>. Enter the permalink and get rid of <code>/\_pages/</code> part. Do not forget the trailing slash!
-   **showInMenu**: By default every page is shown in the main menu. Set it to <code>false</code> if you don't want it to be visible there.

There are two "special" or in other words hardcoded pages that are custom for this theme - **About Page** and **Work Page**. They have some additional front matter that I'd like to share with you.
Special pages do not use <code>page</code> layout so they'll need another property to show up in the main menu.

-   **customPage**: If you want a special page to be visible in the menu you'll have to keep this option set to <code>true</code> along with <code>showInMenu</code>. If false or removed the page will not be visible.
-   **order**: Custom pages can be ordered. Just place a number here.

### How To Add a New Project

Go to the <code>\_projects</code> folder and create a new file. There is a little bit of front matter that you'll have to fill:

## {% highlight ruby linenos %}

name: App
category: App Design
creationDate: 2021-02-01
client: Tesla
role: App Deisgner
website: https://project.website.com
cover: http://path.to.cover.image.jpg
gallery:

-   http://path.to.image1.jpg
-   http://path.to.image2.jpg

---

{% endhighlight %}

I think all of the properties are self-explanatory. Keep in mind that demo projects are using <code>webp</code> format for the images and they are hosted on my server to keep the size of the theme as low as possible. If you keep your images in the <code>images</code> folder (as you should be) the path is <code>/assets/images/image.FORMAT</code>.

### How To Add a New Category

I wanted to keep this theme as light and clean as possible, so the use of external plugins was not an option. Besides, I also wanted to be GitHub Pages compatible.
Adding a category is pretty simple, but some empty file creation is needed. Categories and tags are collections (just like projects) and every collection item require a dedicated file. Here are the steps of new category creation.

1. Go to <code>\_category</code> folder and create new file. For example: <code>documentation.html</code>.
2. Open that file and add <code>category</code> property in the front matter. _Note: Filename and category must be exactly the same._

## {% highlight ruby linenos %}

## category: documentation

{% endhighlight %}

{:start="3"} 3. _Optional_: Go to a post and add category name to the list.

### How To Add a New Tag

I wanted to keep this theme as light and clean as possible, so the use of external plugins was not an option. Besides, I also wanted to be GitHub Pages compatible.
Adding a tag is pretty simple, but some file creation is needed. Categories and tags are collections (just like projects) and every collection item require a dedicated file. Here are the steps of new tag creation.

1. Go to <code>\_tag</code> folder and create new file. For example: <code>jekyll.html</code>.
2. Open that file and add <code>tag</code> property in the front matter. _Note: Filename and tag must be exactly the same._

## {% highlight ruby linenos %}

## tag: jekyll

{% endhighlight %}

{:start="3"} 3. _Optional_: Go to a post and add tag name to the list.

### How To Add a New Author

1. Go to <code>\_data</code> folder and open <code>authors.yml</code> file. Take a look at the examples and add another author.
2. Then go to a specific post and add author's name in the front matter.

{% highlight ruby linenos %}
henry:
name: Henry Dawson
title: Ordinary Gentleman
avatar: /assets/images/user1.webp
{% endhighlight %}

Take a look at the example above. <code>henry</code> is the name that you put in the post's front matter and the <code>name</code> is just a display name that is used thereafter.

### Enable & Configure Disqus Comments

To enable and configure comments you must do the following:

1. Go to <code>\_config.yml</code> and under **Options** enable <code>showComments</code>.
2. Go to <code>\_includes/components/comments.html</code> file and edit your <code>PAGE_URL</code> and <code>PAGE_IDENTIFIER</code> variables. [Read about Disqus](https://disqus.com/admin/install/platforms/universalcode){:target="\_blank"}.

### Formspree (Contact Form)

Go to [Formspree](https://formspree.io/){:target="\_blank"} and register. Create a new project and then a form. Paste form's endpoint to the <code>\_config.yml</code> file, section **Third Party / Social**. Voilà!

### Site Search

This theme use a third-party search library that is completely JavaScript. In the root folder you'll find the <code>search.json</code> file which is basically the search result's config. If you go to <code>\_includes/scripts.html</code> you can also configure the library itself. You can change the settings but make sure you know what you are doing.

### GitHub Pages

Here is the one of many ways to upload the theme to GitHub Pages.

1. Go to [GitHub](https://github.com/){:target="\_blank"} and create a new repository. It can be private or public for now, just don't forget to make it public when you finish editing.
2. Clone your repo and create a new branch called <code>gh-pages</code>.
3. Go to your Henry theme and open <code>\_config.yml</code> file. After <code>url</code> in the **Paths** section write down your full URL. Example: <code>https://githubusername.github.io/repositoryname</code>. Build using <code>bundle exec jekyll build</code>.
4. Copy the contents of <code>\_site</code> folder to the newly created GitHub Pages repo.
5. Then define user by executing two commands: <code>git config user.email "Your Email"</code> and <code>git config user.name "Your Name"</code>.
6. Use <code>git add .</code> to stage all files, then type <code>git commit -m "Initial commit"</code> to make your first commit and that followed by <code>git push -u origin gh-pages</code> to push the changes.
7. Open <code>https://githubusername.github.io/repositoryname</code> (remember, you'll have to make it public). If you want to push new changes to the website, repeat step 6 and in the end just use <code>git push</code>.

That's it! Do not hesitate to ask if you have any questions. Happy blogging!
