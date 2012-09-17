# Require all the previewers
Dir[File.join(File.dirname(__FILE__), 'previewers','*.rb')].each { |f|
  require f
}

class Ruhoh
  module Previewer

  end
end