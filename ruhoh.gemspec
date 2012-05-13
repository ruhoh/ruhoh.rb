$LOAD_PATH.unshift 'lib'
require 'ruhoh/version'

Gem::Specification.new do |s|
  s.name              = "ruhoh"
  s.version           = Ruhoh::Version
  s.date              = Time.now.strftime('%Y-%m-%d')
  s.license           = "http://www.opensource.org/licenses/MIT"
  s.summary           = 'Ruby based library to process your Ruhoh static blog.'
  s.homepage          = "http://github.com/ruhoh/ruhoh.rb"
  s.email             = "plusjade@gmail.com"
  s.authors           = ['Jade Dominguez']
  s.description       = 'Ruhoh is a Universal API for your static blog.'
  s.executables       = ["ruhoh"]
  
  # dependencies defined in Gemfile
  s.add_dependency 'rack', "~> 1.4"
  s.add_dependency 'mustache', "~> 0.99"
  s.add_dependency 'directory_watcher', "~> 1.4"
  s.add_dependency 'redcarpet', "~> 2.1"
  s.add_dependency 'psych', "~> 1.3"
  
  # = MANIFEST =
  s.files = %w[
    Gemfile
    README.md
    Rakefile
    bin/ruhoh
    dash.html
    history.json
    lib/ruhoh.rb
    lib/ruhoh/client/client.rb
    lib/ruhoh/client/help.yml
    lib/ruhoh/compiler.rb
    lib/ruhoh/converters/converter.rb
    lib/ruhoh/converters/markdown.rb
    lib/ruhoh/db.rb
    lib/ruhoh/deployers/s3.rb
    lib/ruhoh/friend.rb
    lib/ruhoh/logger.rb
    lib/ruhoh/page.rb
    lib/ruhoh/parsers/layouts.rb
    lib/ruhoh/parsers/pages.rb
    lib/ruhoh/parsers/partials.rb
    lib/ruhoh/parsers/posts.rb
    lib/ruhoh/parsers/routes.rb
    lib/ruhoh/parsers/site.rb
    lib/ruhoh/previewer.rb
    lib/ruhoh/program.rb
    lib/ruhoh/templaters/base.rb
    lib/ruhoh/templaters/helpers.rb
    lib/ruhoh/templaters/rmustache.rb
    lib/ruhoh/utils.rb
    lib/ruhoh/version.rb
    lib/ruhoh/watch.rb
    ruhoh.gemspec
    scaffolds/layout.html
    scaffolds/page.html
    scaffolds/post.html
    scaffolds/theme/css/style.css
    scaffolds/theme/images/.gitkeep
    scaffolds/theme/layouts/default.html
    scaffolds/theme/layouts/page.html
    scaffolds/theme/layouts/post.html
    scaffolds/theme/partials/.gitkeep
    spec/db_spec.rb
    spec/page_spec.rb
    spec/parsers/layouts_spec.rb
    spec/parsers/pages_spec.rb
    spec/parsers/posts_spec.rb
    spec/parsers/routes_spec.rb
    spec/parsers/site_spec.rb
    spec/setup_spec.rb
    spec/spec_helper.rb
    system_partials/analytics/getclicky
    system_partials/analytics/google
    system_partials/comments/disqus
    system_partials/comments/facebook
    system_partials/comments/intensedebate
    system_partials/comments/livefyre
    system_partials/syntax/google_prettify
  ]
  # = MANIFEST =
end
