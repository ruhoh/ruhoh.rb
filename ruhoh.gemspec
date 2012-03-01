$LOAD_PATH.unshift 'lib'
require 'ruhoh/version'

Gem::Specification.new do |s|
  s.name              = "ruhoh"
  s.version           = Ruhoh::Version
  s.date              = Time.now.strftime('%Y-%m-%d')
  s.summary           = 'Ruby parser for Ruhoh-based static websites.'
  s.homepage          = "http://github.com/plusjade/ruhoh.rb"
  s.email             = "plusjade@gmail.com"
  s.authors           = ['Jade Dominguez']
  s.files            += Dir.glob("lib/**/*")
  s.description       = ''
end
