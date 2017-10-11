Gem::Specification.new do |s|
  s.name        = 'Github Cards'
  s.version     = '0.1.0'
  s.date        = '2017-10-06'
  s.summary     = "Generates HTML based off your github account"
  s.description = "Takes your repos from your github account and parses it into HTML"
  s.authors     = ["Edward Shen"]
  s.email       = 'edward@syllogism.xyz'
  s.files       = ["lib/github-cards.rb"]
  s.homepage    = 'http://github.com/edward-shen/github-cards'
  s.license       = 'MIT'
  s.add_dependency('graphql-client', '~> 0.12.1')
  s.add_dependency('jekyll', '~> 3.6.0')
end
