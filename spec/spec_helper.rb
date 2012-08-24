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

Dir[File.join(File.dirname(__FILE__), "support/**/*.rb")].each {|f| require f}

# Full path to mock blog directory
SampleSitePath = File.expand_path(File.join(File.dirname(__FILE__), '..', '__tmp'))

RSpec.configure do |config|
  config.before(:each){
    FileUtils.remove_dir(SampleSitePath,1) if Dir.exists? SampleSitePath
  }
  config.after(:each) do 
    # Reset all configuration variables after each test.
    Ruhoh.reset
    FileUtils.remove_dir(SampleSitePath,1) if Dir.exists? SampleSitePath
  end
end