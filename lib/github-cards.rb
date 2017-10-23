require "graphql/client"
require "graphql/client/http"
require "time"

class GithubCards < Liquid::Tag

  CONFIG = Jekyll.configuration({})['github_cards']
  GITHUB_ACCESS_TOKEN = CONFIG['github_access_token']

  # Set variables and defaults
  SHOW_LICENSE = CONFIG['show_license'].nil? ? true : CONFIG['show_license']
  SHOW_LANGUAGE = CONFIG['show_language'].nil? ? true : CONFIG['show_language']
  SHOW_USER_ICON = CONFIG['show_user_icon'].nil? ? true : CONFIG['show_user_icon']
  SHOW_STARS = CONFIG['show_stars'].nil? ? true : CONFIG['show_stars']
  SHOW_FORKS = CONFIG['show_forks'].nil? ? true : CONFIG['show_forks']

  # Graciously stolen from somewhere on github <3
  HTTPAdapter = GraphQL::Client::HTTP.new("https://api.github.com/graphql") do
    def headers(context)
      unless GITHUB_ACCESS_TOKEN
        fail "Missing GitHub access token"
      end

      { "Authorization" => "Bearer #{GITHUB_ACCESS_TOKEN}" }
    end
  end

  # Fetch latest schema on init, this will make a network request
  # Github's schema literally changes from day to day. I would cache it otherwise.
  Schema = GraphQL::Client.load_schema(HTTPAdapter)
  Client = GraphQL::Client.new(schema: Schema, execute: HTTPAdapter)

  # Various Schemas
  NYoursRepoQuery = GithubCards::Client.parse <<-'GRAPHQL'
  query($num: Int!){
    viewer {
      avatarUrl
      login
      repositories(first: $num, privacy: PUBLIC, orderBy: {field: CREATED_AT, direction: DESC}) {
        edges {
          node {
            name
            description
            license
            primaryLanguage {
              color
              name
            }
            pushedAt
            stargazers {
              totalCount
            }
            forks {
              totalCount
            }
          }
        }
      }
    }
  }
  GRAPHQL

  SingleYoursRepoQuery = GithubCards::Client.parse <<-'GRAPHQL'
  query($repo_name: String!){
    viewer {
      avatarUrl
      login
      repository(name: $repo_name) {
        name
        description
        license
        primaryLanguage {
          color
          name
        }
        pushedAt
        stargazers {
          totalCount
        }
        forks {
          totalCount
        }
      }
    }
  }
  GRAPHQL

  NRepoQuery = GithubCards::Client.parse <<-'GRAPHQL'
  query($username: String!, $num: Int!){
    user(login: $username) {
      avatarUrl
      login
      repositories(first: $num, privacy: PUBLIC, orderBy: {field: CREATED_AT, direction: DESC}) {
        edges {
          node {
            name
            description
            license
            primaryLanguage {
              color
              name
            }
            pushedAt
            stargazers {
              totalCount
            }
            forks {
              totalCount
            }
          }
        }
      }
    }
  }
  GRAPHQL

  SingleRepoQuery = GithubCards::Client.parse <<-'GRAPHQL'
  query($username: String!, $repo_name: String!){
    user(login: $username) {
      avatarUrl
      login
      repository(name: $repo_name) {
        pushedAt
        name
        description
        primaryLanguage {
          color
          name
        }
        stargazers {
          totalCount
        }
        forks {
          totalCount
        }
      }
    }
  }
  GRAPHQL

  def initialize(tag_name, args, tokens)
    @args = args.split(" ")
    super
  end

  # context (?) -> String
  # Returns the HTML for the cards, depending on the passed args
  def render(context)
    @output = "<section class=\"gh-cards\">\n"
    if @args.length == 0
      show_n_yours(30)
    elsif @args.length == 1
      # User wants to show n of their repos
      if number_or_nil(@args[0])
        show_n_yours(@args[0].to_i)
      else # User wants to show one of their repos
        show_repo_yours(@args[0])
      end
    elsif @args.length == 2
      # User wants to show n of someone else's repos
      if number_or_nil(@args[1])
        show_n_repos(@args[0], @args[1].to_i)
      else # User wants to show one of someone else's repo
        show_repo(@args[0], @args[1])
      end
    end
    @output += "</section>"
  end

  # String -> (Integer or nil)
  # Returns the number if the string is a valid integer, else return nil.
  # param string The string to be checked
  def number_or_nil(string)
    num = string.to_i
    num if num.to_s == string
  end

  def show_n_yours(num_repos)
    result = GithubCards::Client.query(NYoursRepoQuery, variables: { num: (num_repos <= 30) ? num_repos : 30 }).data.viewer
    for repo in result.repositories.edges do
      get_repo_html(repo.node, result.login, result.avatar_url)
    end
  end

  def show_repo_yours(repo_name)
    result = GithubCards::Client.query(SingleYoursRepoQuery, variables: { repo_name: repo_name }).data.viewer
    get_repo_html(result.repository, result.login, result.avatar_url)
  end

  def show_n_repos(username, num_repos)
    result = GithubCards::Client.query(NRepoQuery, variables: { username: username, num: (num_repos <= 30) ? num_repos : 30 }).data.user
    for repo in result.repositories.edges do
      get_repo_html(repo.node, result.login, result.avatar_url)
    end
  end

  def show_repo(username, repo_name)
    result = GithubCards::Client.query(SingleRepoQuery, variables: { username: username, repo_name: repo_name }).data.user
    get_repo_html(result.repository, result.login, result.avatar_url)
  end

  # GraphQLObject -> String
  # Returns the HTML for a single repo
  # param repo The object from the GraphQL call that is that the repo's root level.
  # param username The username of the user
  # param avatar_url the url of the user
  def get_repo_html(repo, username, avatar_url)
    @output += %Q(
      <article class="gh-card" data-username="#{username}" data-repo="#{repo.name}">
        <section class="gh-card-top">
          #{show_user_icon(username, avatar_url)}
          <section class="gh-card-info">
            <a href="https://github.com/#{username}/#{repo.name}"><h4>#{repo.name}</h4></a>
            <div class="gh-card-details">
              <p>Created by <a href="https://github.com/#{username}">#{username}</a></p>
              <p>Last updated on <a href="https://github.com/#{username}/#{repo.name}/commits/master">#{get_time(repo.pushed_at)}</a>
              </p>
            </div>
          </section>
          #{show_repo_language(repo.primary_language)}
        </section>

        <p class="gh-card-desc">#{repo.description || "<i class=\"text-grey\">No description provided.</i>"}</p>

        #{if SHOW_STARS || SHOW_FORKS || SHOW_LICENSE
          %Q(<section class="gh-card-bottom text-grey">
            #{show_stars(repo.stargazers.total_count.to_s)}
            #{show_forks(repo.forks.total_count.to_s)}
            #{show_license(repo.license)}
          </section>)
        end}
      </article>\n\n)
  end

  # GraphQLObject -> String
  # Returns the date of the last push time in a readable format.
  # param ISO8601 formatted string
  def get_time(push_time)
    t = Time.parse(push_time)
    t.strftime("%Y-%m-%d")
  end

  def show_user_icon(username, avatar_url)
    if SHOW_USER_ICON
      %Q(<a href="https://github.com/#{username}"><img class="gh-card-avatar" src="#{avatar_url}" alt="User icon"></a>)
    end
  end

  # GraphQLObject -> String
  # Returns the HTML for displaying the primary language, if one exists.
  # param lang the object containing the language name and color.
  def show_repo_language(lang)
    if lang && SHOW_LANGUAGE # Checks if lang is nil
      %Q(
      <section class="gh-card-lang">
        <p class="text-grey">#{lang.name}</p>
        <svg aria-hidden="true" version="1.1" viewBox="0 0 14 16">
          <circle cx="7" cy="7" r="7" fill="#{lang.color}" />
        </svg>
      </section>)
    end
  end


  def show_stars(stars)
    if SHOW_STARS
      %Q(<svg aria-hidden="true" version="1.1" viewBox="0 0 14 16">
        <path fill-rule="evenodd" d="M14 6l-4.9-.64L7 1 4.9 5.36 0 6l3.6 3.26L2.67 14 7 11.67 11.33 14l-.93-4.74z" />
      </svg>
      <p class="star-count">#{stars}</p>)
    end
  end

  def show_forks(forks)
    if SHOW_FORKS
      %Q(<svg aria-hidden="true" version="1.1" viewBox="0 0 10 16">
        <path fill-rule="evenodd" d="M8 1a1.993 1.993 0 0 0-1 3.72V6L5 8 3 6V4.72A1.993 1.993 0 0 0 2 1a1.993 1.993 0 0 0-1 3.72V6.5l3 3v1.78A1.993 1.993 0 0 0 5 15a1.993 1.993 0 0 0 1-3.72V9.5l3-3V4.72A1.993 1.993 0 0 0 8 1zM2 4.2C1.34 4.2.8 3.65.8 3c0-.65.55-1.2 1.2-1.2.65 0 1.2.55 1.2 1.2 0 .65-.55 1.2-1.2 1.2zm3 10c-.66 0-1.2-.55-1.2-1.2 0-.65.55-1.2 1.2-1.2.65 0 1.2.55 1.2 1.2 0 .65-.55 1.2-1.2 1.2zm3-10c-.66 0-1.2-.55-1.2-1.2 0-.65.55-1.2 1.2-1.2.65 0 1.2.55 1.2 1.2 0 .65-.55 1.2-1.2 1.2z"/>
      </svg>
      <p class="fork-count">#{forks}</p>)
    end
  end

  # GraphQLObject -> String
  # Returns the HTML for displaying the license, if one exists.
  # param lang the object containing the license.
  def show_license(license)
    # Checks if lang is nil and we want to show the license
    if license && SHOW_LICENSE
      %Q(
      <section class="gh-card-license">
        <p class="text-grey">#{license}</p>
        <svg aria-hidden="true" height="16" version="1.1" viewBox="0 0 14 16" width="14"><path fill-rule="evenodd" d="M7 4c-.83 0-1.5-.67-1.5-1.5S6.17 1 7 1s1.5.67 1.5 1.5S7.83 4 7 4zm7 6c0 1.11-.89 2-2 2h-1c-1.11 0-2-.89-2-2l2-4h-1c-.55 0-1-.45-1-1H8v8c.42 0 1 .45 1 1h1c.42 0 1 .45 1 1H3c0-.55.58-1 1-1h1c0-.55.58-1 1-1h.03L6 5H5c0 .55-.45 1-1 1H3l2 4c0 1.11-.89 2-2 2H2c-1.11 0-2-.89-2-2l2-4H1V5h3c0-.55.45-1 1-1h4c.55 0 1 .45 1 1h3v1h-1l2 4zM2.5 7L1 10h3L2.5 7zM13 10l-1.5-3-1.5 3h3z"></path></svg>
      </section>)
    end
  end
end

Liquid::Template.register_tag('ghcards', GithubCards)
