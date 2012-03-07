$LOAD_PATH.unshift 'lib'
require 'ruhoh/version'

Gem::Specification.new do |s|
  s.name              = "ruhoh"
  s.version           = Ruhoh::Version
  s.date              = Time.now.strftime('%Y-%m-%d')
  s.license           = "http://unlicense.org/"
  s.summary           = 'Ruby based library to process your Ruhoh static blog.'
  s.homepage          = "http://github.com/plusjade/ruhoh.rb"
  s.email             = "plusjade@gmail.com"
  s.authors           = ['Jade Dominguez']
  s.description       = 'Ruhoh is a Universal API for your static blog.'
  s.executables       = ["ruhoh"]
  
  # dependencies defined in Gemfile
  s.add_dependency 'rack', "~> 1.4"
  s.add_dependency 'mustache', "~> 0.99"
  s.add_dependency 'directory_watcher', "~> 1.4"
  s.add_dependency 'maruku', "~> 0.6"
  
  # = MANIFEST =
  s.files = %w[
    Gemfile
    README.md
    bin/ruhoh
    lib/ruhoh.rb
    lib/ruhoh/client.rb
    lib/ruhoh/compiler.rb
    lib/ruhoh/converters/converter.rb
    lib/ruhoh/db.rb
    lib/ruhoh/page.rb
    lib/ruhoh/parsers/layouts.rb
    lib/ruhoh/parsers/pages.rb
    lib/ruhoh/parsers/partials.rb
    lib/ruhoh/parsers/posts.rb
    lib/ruhoh/parsers/routes.rb
    lib/ruhoh/parsers/site.rb
    lib/ruhoh/preview.rb
    lib/ruhoh/templaters/helper_mustache.rb
    lib/ruhoh/templaters/templater.rb
    lib/ruhoh/utils.rb
    lib/ruhoh/version.rb
    lib/ruhoh/watch.rb
    ruhoh.gemspec
  ]
  # = MANIFEST =
end
