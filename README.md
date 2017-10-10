# Github Cards

Github Cards is a Jekyll to create an easy-to-reference and stylable GitHub Card.

## Installation

This is still an in-progress work.

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

Remember, you don't need *any* permissions other than the default scope

Once you got one, add it to your `_config.yml`:
```
...
github_access_token: "abc123"
...
```


Then, re-run `bundle install`.

You'll also need to do something to add your token, I'll figure out how to make that easier for using your own.

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

## Planned features
- [x] Specify single card
- [x] Implement get n cards from your repo
- [ ] Implement infinite repos
- [ ] Clean up codebase
- [ ] Bug fixes
- [ ] Add small js to update stars and forks on load
