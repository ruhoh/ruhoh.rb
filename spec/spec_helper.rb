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
  config.after(:each) do 
    # Reset all configuration variables after each test.
    Ruhoh.reset
  end
end

SampleSitePath = '__tmp'

Dir.rmdir SampleSitePath if Dir.exists? SampleSitePath
Dir.mkdir SampleSitePath
