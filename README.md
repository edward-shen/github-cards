# Github Cards

Github Cards is a Jekyll plugin to create an easy-to-reference and stylable GitHub Card using a custom Liquid tag.

Here's an example of what it does, in context:
![example usage](https://i.imgur.com/m4K8Gzt.png)
## History

In the past, there was a 1-liner (well, two, really) that would generate a nice looking github card.
You would call it like so:
```html
<div class="github-card" data-github="edward-shen/MMM-MBTA" data-width="400" data-height="157" data-theme="default"></div>
```

And place this line at the bottom of your website.
```html
<script src="//cdn.jsdelivr.net/github-cards/latest/widget.js"></script>
```

This is nice, except for a few things:
1. Generates an iframe. This is dangerous, because you now rely on an external webserver to not serve malware.
2. Relatively computationally complex for the client. Why require the user to generate HTML when it can simply served from the server?
3. Difficult to style. You're kinda forced to follow the styling provided by the author of that script.

To be fair, it does have its uses, especially in forums that allow users to post raw HTML (But that in itself should be questioned), or
if you're generating your websites manually.

Github Cards adapts this idea for use with Jekyll, with provides the following benefits.

1. Safe. No need for iframes or external sources.
2. Static. For the user, it's as lightweight as text -- the rendered output is pure HTML.
3. Customizable. Don't like my style? Don't worry. You can customize it to any degree you want. Every major section has either a `css` class or semantic tag -- in some cases, both!

## Installation

This is still an in-progress work.

First, make a folder (if one doesn't exist) in your site root called `_plugins`.
This folder should be on the same level as `_site`. Then, drag github-cards.rb into the plugins.

In your jekyll `Gemfile` add the gem `graphql-client` to the Jekyll plugins group:

```
group :jekyll_plugins do

   ...

   gem "graphql-client"
end
```
Additionally, you'll need to create a Github Personal Access Token. Fear not, you
don't need any permissions other than the default scope.

See [this Github article](https://help.github.com/articles/creating-an-access-token-for-command-line-use)
on how to create your own.

**Remember, you don't need *any* permissions other than the default scope.**

Once you got one, add it to your `_config.yml`:
```
...
github_access_token: "abc123"
...
```


Then, re-run `bundle install`.

## Usage

By default, Github Cards only shows HTML. This is intentional, as the user can then style it themselves. However,
I have provided two files as a template: `style.css` and `_github-cards.scss`.

They both provide the same functionality. Note that you may need to increase specificity if your other CSS/Sass
overrides these styles.

To include these styles, simply add `@import "github-cards";` or `@import "style.css";`.


To list all your repos, add the following liquid tag:
```
{% ghcards %}
```
This will produce cards for the first 30 most recently created repos. This is useful for listing out your repos for a projects page.

### Listing multiple repos
To show the first n (up to 30) of your repos:
```
{% ghcards n %}
```

To show the first n (up to 30) of somebody's repos:
```
{% ghcards username n %}
```

### Listing single repos
To show a single repo of your own:
```
{% ghcards repo %}
```

To show a single repo, add the following liquid tag:
```
{% ghcards username repo %}
```

For example, if you wanted to show only this repo, you'd use:
```
{% ghcards edward-shen github-cards %}
```

## Things to know

### Static stars and forks
Unfortunately, by nature of jekyll, everything is static when you generate your website.
This means your stars and forks won't update if someone else stars or forks your repo
after you generate you site. The solution? I've created a small, pure JS script that updates every
github card with the newest data.


## FAQ
**Q:** WTF I tried added it and it's all huge and not formatted nicely like it should be!

**A:** You didn't install any stylesheets. Either include one of the templates or style it yourself.




## Planned features
- [x] Specify single card
- [x] Implement get n cards from your repo
- [ ] Implement infinite repos
- [ ] Clean up codebase
- [ ] Bug fixes
- [ ] Add small js to update stars and forks on load
