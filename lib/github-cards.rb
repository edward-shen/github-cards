=begin
FUCK THESE MULTILINE COMMENT SYNTAX

module Jekyll
    class  < Liquid::Tag

      def initialize(tag_name, text, tokens)
        priority :normal
        super
      end

      def render(context)
        "#{@text} #{Time.now}"
      end
    end
end

Liquid::Template.register_tag('github-card', Jekyll::GRHG)

=end

require "graphql/client"
require "graphql/client/http"
require "time"

class GithubCards < Liquid::Tag

  # Graciously stolen from somewhere on github <3
  HTTPAdapter = GraphQL::Client::HTTP.new("https://api.github.com/graphql") do
    def headers(context)
#      unless token = context[:access_token] || Application.secrets.github_access_token
        # $ GITHUB_ACCESS_TOKEN=abc123 bin/rails server
        #   https://help.github.com/articles/creating-an-access-token-for-command-line-use
#        fail "Missing GitHub access token"
#      end

      token="f960d2a94d3598bc746733c55f29efb5eabdfe1c"

      {
        "Authorization" => "Bearer #{token}"
      }
    end
  end

  # Fetch latest schema on init, this will make a network request
  # Github's schema literally changes from day to day.
  Schema = GraphQL::Client.load_schema(HTTPAdapter)

  Client = GraphQL::Client.new(schema: Schema, execute: HTTPAdapter)

  RepoQuery = GithubCards::Client.parse <<-'GRAPHQL'
  query {
    viewer {
      avatarUrl
      name
      login
      repositories(first:30 privacy:PUBLIC) {
        edges {
          node {
            name
            description
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


  def initialize(tag_name, username, tokens)
    super
  end

  def render(context)

  result = GithubCards::Client.query(RepoQuery).data.viewer
  output = "<section class=\"gh-cards\">\n"
  avatar_url = result.avatar_url
  username = result.login
  for repo in result.repositories.edges do
    output +=
    %Q(
  <article class="gh-card">
    <section class="gh-card-top">
      <a href="https://github.com/#{username}"><img class="gh-card-avatar" src="#{avatar_url}" alt="User icon"></a>
      <section class="gh-card-info">
        <a href="https://github.com/#{username}/#{repo.node.name}"><h4>#{repo.node.name}</h4></a>
        <div class="gh-card-details">
          <p>Created by <a href="https://github.com/#{username}">#{username}</a></p>
          <p>Last updated on <a href="https://github.com/#{username}/#{repo.node.name}/commits/master"> #{
            t = Time.parse(repo.node.pushed_at)
            t.strftime("%Y-%m-%d")}</a></p>
        </div>
      </section>
      #{if repo.node.primary_language
      %Q(
        <section class="gh-card-lang">
      <p class="text-grey">
        #{repo.node.primary_language.name}</p>
        <svg aria-hidden="true" version="1.1" viewBox="0 0 14 16">
        <circle cx="7" cy="7" r="7" fill="#{repo.node.primary_language.color}" />
      </svg>
        </section>)
      end
      }

    </section>

    <p class="gh-card-desc">#{repo.node.description || "<i class=\"text-grey\">No description provided.</i>"}</p>

    <section class="gh-card-bottom text-grey">
      <svg aria-hidden="true" version="1.1" viewBox="0 0 14 16">
        <path fill-rule="evenodd" d="M14 6l-4.9-.64L7 1 4.9 5.36 0 6l3.6 3.26L2.67 14 7 11.67 11.33 14l-.93-4.74z" />
      </svg>
      <p>#{repo.node.stargazers.total_count.to_s}</p>
      <svg aria-hidden="true" version="1.1" viewBox="0 0 10 16">
        <path fill-rule="evenodd" d="M8 1a1.993 1.993 0 0 0-1 3.72V6L5 8 3 6V4.72A1.993 1.993 0 0 0 2 1a1.993 1.993 0 0 0-1 3.72V6.5l3 3v1.78A1.993 1.993 0 0 0 5 15a1.993 1.993 0 0 0 1-3.72V9.5l3-3V4.72A1.993 1.993 0 0 0 8 1zM2 4.2C1.34 4.2.8 3.65.8 3c0-.65.55-1.2 1.2-1.2.65 0 1.2.55 1.2 1.2 0 .65-.55 1.2-1.2 1.2zm3 10c-.66 0-1.2-.55-1.2-1.2 0-.65.55-1.2 1.2-1.2.65 0 1.2.55 1.2 1.2 0 .65-.55 1.2-1.2 1.2zm3-10c-.66 0-1.2-.55-1.2-1.2 0-.65.55-1.2 1.2-1.2.65 0 1.2.55 1.2 1.2 0 .65-.55 1.2-1.2 1.2z"/>
      </svg>
      <p>#{repo.node.forks.total_count.to_s}</p>
    </section>
  </article>\n\n)
  end
  output += "</section>"
  # output += "</section>\n<style>#{File.read('style.css')}</style>"
  # File.write("testfile.html", output)
  end
end

Liquid::Template.register_tag('ghcard', GithubCards)
