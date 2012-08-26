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
  s.add_dependency 'nokogiri', "~> 1.5"
  
  # = MANIFEST =
  s.files = %w[
    Gemfile
    README.md
    Rakefile
    bin/ruhoh
    history.json
    lib/ruhoh.rb
    lib/ruhoh/client/client.rb
    lib/ruhoh/client/console_methods.rb
    lib/ruhoh/client/help.yml
    lib/ruhoh/compiler.rb
    lib/ruhoh/compilers/rss.rb
    lib/ruhoh/compilers/theme.rb
    lib/ruhoh/config.rb
    lib/ruhoh/converters/converter.rb
    lib/ruhoh/converters/markdown.rb
    lib/ruhoh/db.rb
    lib/ruhoh/deployers/s3.rb
    lib/ruhoh/friend.rb
    lib/ruhoh/logger.rb
    lib/ruhoh/page.rb
    lib/ruhoh/parsers/javascripts.rb
    lib/ruhoh/parsers/layouts.rb
    lib/ruhoh/parsers/pages.rb
    lib/ruhoh/parsers/partials.rb
    lib/ruhoh/parsers/payload.rb
    lib/ruhoh/parsers/posts.rb
    lib/ruhoh/parsers/routes.rb
    lib/ruhoh/parsers/scaffolds.rb
    lib/ruhoh/parsers/site.rb
    lib/ruhoh/parsers/stylesheets.rb
    lib/ruhoh/parsers/theme_config.rb
    lib/ruhoh/parsers/widgets.rb
    lib/ruhoh/paths.rb
    lib/ruhoh/previewer.rb
    lib/ruhoh/program.rb
    lib/ruhoh/templaters/asset_helpers.rb
    lib/ruhoh/templaters/base_helpers.rb
    lib/ruhoh/templaters/helpers.rb
    lib/ruhoh/templaters/rmustache.rb
    lib/ruhoh/urls.rb
    lib/ruhoh/utils.rb
    lib/ruhoh/version.rb
    lib/ruhoh/watch.rb
    ruhoh.gemspec
    spec/config_spec.rb
    spec/db_spec.rb
    spec/page_spec.rb
    spec/parsers/layouts_spec.rb
    spec/parsers/pages_spec.rb
    spec/parsers/posts_spec.rb
    spec/parsers/routes_spec.rb
    spec/parsers/site_spec.rb
    spec/setup_spec.rb
    spec/spec_helper.rb
    spec/support/shared_contexts.rb
    system/dash.html
    system/partials/categories_list.html
    system/partials/pages_list.html
    system/partials/posts_collate.html
    system/partials/posts_list.html
    system/partials/posts_summary.html
    system/partials/tags_list.html
    system/scaffolds/draft.html
    system/scaffolds/layout.html
    system/scaffolds/page.html
    system/scaffolds/post.html
    system/widgets/analytics/config.yml
    system/widgets/analytics/layouts/getclicky.html
    system/widgets/analytics/layouts/google.html
    system/widgets/comments/config.yml
    system/widgets/comments/layouts/disqus.html
    system/widgets/comments/layouts/facebook.html
    system/widgets/comments/layouts/intensedebate.html
    system/widgets/comments/layouts/livefyre.html
    system/widgets/google_prettify/config.yml
    system/widgets/google_prettify/layouts/google_prettify.html
  ]
  # = MANIFEST =
end
