$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), *%w[lib]))
require 'rubygems'
require 'rake'
require 'bundler'
require 'ruhoh/version'
require 'rspec/core/rake_task'

name = Dir['*.gemspec'].first.split('.').first
gemspec_file = "#{name}.gemspec"
gem_file = "#{name}-#{Ruhoh::VERSION}.gem"

task :release => :build do
  sh "git commit --allow-empty -m 'Release #{Ruhoh::VERSION}'"
  sh "git tag v#{Ruhoh::VERSION}"
  sh "git push origin master --tags"
  sh "git push origin v#{Ruhoh::VERSION}"
  sh "gem push pkg/#{name}-#{Ruhoh::VERSION}.gem"
end

task :build do
  sh "mkdir -p pkg"
  sh "gem build #{gemspec_file}"
  sh "mv #{gem_file} pkg"
end

## Tests

RSpec::Core::RakeTask.new('spec')

desc "Run tests"
task :default => :spec