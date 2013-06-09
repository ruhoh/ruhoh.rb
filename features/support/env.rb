require 'fileutils'
require 'rspec/expectations'
require 'capybara/cucumber'
World(RSpec::Matchers)

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'ruhoh'
