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

---
### To be implemented features

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

## Planned features
- [ ] Specify single card
- [ ] Implement get n cards from your repo
- [ ] Bug fixes
