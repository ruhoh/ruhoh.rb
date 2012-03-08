require 'rubygems'
require 'bundler/setup'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'ruhoh'

RSpec.configure do |config|
  # some (optional) config here
end

SampleSitePath = File.expand_path(File.join(File.dirname(__FILE__), '../scaffolds/blog'))

