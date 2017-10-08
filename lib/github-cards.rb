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

  output = "<section>\n"
  img_url = result.avatar_url
  for repo in result.repositories.edges do
    output +=
# TFW this has to be the formatting or else it looks shit.
%Q(  <article class="gh-card">
    <img src="#{img_url}" alt="User icon">
    <h4>#{repo.node.name}</h4>
    <button type="button">Stars #{repo.node.stargazers.total_count.to_s}</button>
    <p>#{repo.node.description || "No description provided"}</p>
    <section class="gh-card-bottom">
  </article>\n\n)
  end
  output += "</section>"
  File.write("testfile.html", output)
end
