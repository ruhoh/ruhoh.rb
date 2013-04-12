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
  s.add_dependency 'directory_watcher', "~> 1.4.1"
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
    lib/ruhoh/client.rb
    lib/ruhoh/console_methods.rb
    lib/ruhoh/converter.rb
    lib/ruhoh/converters/markdown.rb
    lib/ruhoh/db.rb
    lib/ruhoh/friend.rb
    lib/ruhoh/logger.rb
    lib/ruhoh/programs/compile.rb
    lib/ruhoh/programs/preview.rb
    lib/ruhoh/programs/watch.rb
    lib/ruhoh/resources/_base/collection.rb
    lib/ruhoh/resources/_base/collection_view.rb
    lib/ruhoh/resources/_base/compiler.rb
    lib/ruhoh/resources/_base/model.rb
    lib/ruhoh/resources/_base/model_view.rb
    lib/ruhoh/resources/_page/collection_view.rb
    lib/ruhoh/resources/_page/compiler.rb
    lib/ruhoh/resources/_page/model.rb
    lib/ruhoh/resources/_page/model_view.rb
    lib/ruhoh/resources/_page/previewer.rb
    lib/ruhoh/resources/dash/collection.rb
    lib/ruhoh/resources/dash/model.rb
    lib/ruhoh/resources/dash/previewer.rb
    lib/ruhoh/resources/data/collection.rb
    lib/ruhoh/resources/data/collection_view.rb
    lib/ruhoh/resources/data/watcher.rb
    lib/ruhoh/resources/javascripts/collection.rb
    lib/ruhoh/resources/javascripts/collection_view.rb
    lib/ruhoh/resources/layouts/client.rb
    lib/ruhoh/resources/layouts/collection.rb
    lib/ruhoh/resources/layouts/model.rb
    lib/ruhoh/resources/media/collection.rb
    lib/ruhoh/resources/media/compiler.rb
    lib/ruhoh/resources/media/model.rb
    lib/ruhoh/resources/media/static_assets.rb
    lib/ruhoh/resources/pages/client.rb
    lib/ruhoh/resources/pages/collection.rb
    lib/ruhoh/resources/pages/collection_view.rb
    lib/ruhoh/resources/pages/compiler.rb
    lib/ruhoh/resources/pages/model.rb
    lib/ruhoh/resources/pages/model_view.rb
    lib/ruhoh/resources/pages/watcher.rb
    lib/ruhoh/resources/paginator/collection.rb
    lib/ruhoh/resources/paginator/previewer.rb
    lib/ruhoh/resources/partials/collection.rb
    lib/ruhoh/resources/partials/model.rb
    lib/ruhoh/resources/partials/watcher.rb
    lib/ruhoh/resources/posts/client.rb
    lib/ruhoh/resources/posts/collection.rb
    lib/ruhoh/resources/posts/collection_view.rb
    lib/ruhoh/resources/posts/compiler.rb
    lib/ruhoh/resources/posts/model.rb
    lib/ruhoh/resources/posts/model_view.rb
    lib/ruhoh/resources/posts/watcher.rb
    lib/ruhoh/resources/routes/collection.rb
    lib/ruhoh/resources/scaffolds/collection.rb
    lib/ruhoh/resources/scaffolds/model.rb
    lib/ruhoh/resources/stylesheets/collection.rb
    lib/ruhoh/resources/stylesheets/collection_view.rb
    lib/ruhoh/resources/theme/collection.rb
    lib/ruhoh/resources/theme/compiler.rb
    lib/ruhoh/resources/theme/watcher.rb
    lib/ruhoh/resources/widgets/collection.rb
    lib/ruhoh/resources/widgets/collection_view.rb
    lib/ruhoh/resources/widgets/watcher.rb
    lib/ruhoh/resources_interface.rb
    lib/ruhoh/utils.rb
    lib/ruhoh/version.rb
    lib/ruhoh/views/helpers/categories.rb
    lib/ruhoh/views/helpers/tags.rb
    lib/ruhoh/views/master_view.rb
    lib/ruhoh/views/rmustache.rb
    ruhoh.gemspec
    spec/spec_helper.rb
    spec/support/shared_contexts.rb
    system/dash/index.html
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
