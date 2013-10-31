module Ruhoh::Plugins
  class LocalPluginsPlugin
    include Plugin

    initializer 'ruhoh.local_plugins' do
      plugins = Dir[File.join(@base, "plugins", "**/*.rb")]
      plugins.each { |f| require f }
    end
  end
end