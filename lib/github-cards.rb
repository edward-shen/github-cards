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

module GITHUB

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
  Schema = GraphQL::Client.load_schema(HTTPAdapter)

  Client = GraphQL::Client.new(schema: Schema, execute: HTTPAdapter)

  RepoQuery = GITHUB::Client.parse <<-'GRAPHQL'
  query {
    viewer {
      avatarUrl
      login
      repositories(first:30 privacy:PUBLIC) {
        edges {
          node {
            name
            description
            stargazers {
              totalCount
            }
            forks {
              totalCount
            }
            languages(first: 1 orderBy:{field:SIZE, direction:DESC}) {
              edges {
                node {
                  name
                }
              }
            }
          }
        }
      }
    }
  }
  GRAPHQL

  result = GITHUB::Client.query(RepoQuery).data.viewer

  output = "<section class=\"gh-cards\">\n"
  avatar_url = result.avatar_url
  username = result.login
  for repo in result.repositories.edges do
    output +=
# TFW this has to be the formatting or else it looks shit.
%Q(  <article class="gh-card">
    <section class="gh-card-top">
      <a href="https://github.com/#{username}"><img class="gh-card-avatar" src="#{avatar_url}" alt="User icon"></a>
      <div class="gh-card-info">
        <h4><a href="https://github.com/#{username}/#{repo.node.name}">#{repo.node.name}</a></h4>
        <p>Created by <a href="https://github.com/#{username}">#{username}</a></p>
      </div>
      <p class="gh-card-lang">#{
        if repo.node.languages.edges.length != 0
          repo.node.languages.edges.first.node.name
        else
       ""
        end}</p>
    </section>

    <p class="gh-card-desc">#{repo.node.description || "<i>No description provided</i>"}</p>

    <section class="gh-card-bottom">
      <svg aria-hidden="true" height="16" version="1.1" viewBox="0 0 14 16" width="14">
        <path fill-rule="evenodd" d="M14 6l-4.9-.64L7 1 4.9 5.36 0 6l3.6 3.26L2.67 14 7 11.67 11.33 14l-.93-4.74z" />
      </svg>#{repo.node.stargazers.total_count.to_s}
      <svg aria-hidden="true" height="16" version="1.1" viewBox="0 0 10 16" width="10">
        <path fill-rule="evenodd" d="M8 1a1.993 1.993 0 0 0-1 3.72V6L5 8 3 6V4.72A1.993 1.993 0 0 0 2 1a1.993 1.993 0 0 0-1 3.72V6.5l3 3v1.78A1.993 1.993 0 0 0 5 15a1.993 1.993 0 0 0 1-3.72V9.5l3-3V4.72A1.993 1.993 0 0 0 8 1zM2 4.2C1.34 4.2.8 3.65.8 3c0-.65.55-1.2 1.2-1.2.65 0 1.2.55 1.2 1.2 0 .65-.55 1.2-1.2 1.2zm3 10c-.66 0-1.2-.55-1.2-1.2 0-.65.55-1.2 1.2-1.2.65 0 1.2.55 1.2 1.2 0 .65-.55 1.2-1.2 1.2zm3-10c-.66 0-1.2-.55-1.2-1.2 0-.65.55-1.2 1.2-1.2.65 0 1.2.55 1.2 1.2 0 .65-.55 1.2-1.2 1.2z"/>
      </svg>#{repo.node.forks.total_count.to_s}
    </section>
  </article>\n\n)
  end
  output += "</section>\n<style>#{File.read('style.css')}</style>"
  File.write("testfile.html", output)
end
