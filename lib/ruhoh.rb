# encoding: UTF-8
Encoding.default_internal = 'UTF-8'
require 'json'
require 'time'
require 'ruhoh/time'
require 'cgi'
require 'fileutils'
require 'ostruct'
require 'delegate'
require 'digest'
require 'observer'
require 'set'

require 'silly'

require 'ruhoh/logger'
require 'ruhoh/utils'
require 'ruhoh/friend'

require 'ruhoh/cascade'
require 'ruhoh/query'
require 'ruhoh/config'
require 'ruhoh/cache'

require 'ruhoh/summarizer'
require 'ruhoh/converter'
require 'ruhoh/view_renderer'

require 'ruhoh/plugins/plugin'

require 'ruhoh/collections/collections'

class Ruhoh
  class << self
    attr_accessor :log
    attr_reader :root
  end

  attr_accessor :log, :env
  attr_reader :root, :cache, :collections, :query

  Root = File.expand_path(File.join(File.dirname(__FILE__), '..'))
  @log = Ruhoh::Logger.new
  @root = Root

  def initialize(opts={})
    self.class.log.log_file = opts[:log_file] if opts[:log_file] #todo
    @base = opts[:source] ? opts[:source] : Dir.getwd

    Query.paths.clear
    Query.append_path(File.join(Root, "system"))
    Query.append_path(@base)

    Silly::UrlSlug.add_extensions(Ruhoh::Converter.extensions)

    ruhoh = self
    Silly::PageModel.before_data = -> data {
      return data if data["permalink"]
      collection = data["id"].split('/').first
      config = ruhoh.config.collection(collection)
      return data unless config

      config.merge(data)
    }


    @cache = Ruhoh::Cache.new(self)
    @collections = Ruhoh::Collections.new(self)
  end

  def master_view(item)
    Ruhoh::Views::Renderer.new(self, item)
  end

  def query
    Query.new
  end

  def config
    return @config if @config
    @config = Ruhoh::Config.new(self)
    @config.touch
    @config
  end

  def cascade
    return @cascade if @cascade
    @cascade = Ruhoh::Cascade.new(config)
    @cascade.base = @base
    config.touch

    @cascade
  end

  def setup_plugins
    enable_sprockets = config['asset_pipeline']['enable'] rescue false
    if enable_sprockets
      Ruhoh::Friend.say { green "=> Oh boy! Asset pipeline enabled by way of sprockets =D" }
      sprockets = Dir[File.join(cascade.system, "plugins", "sprockets", "**/*.rb")]
      sprockets.each {|f| require f }
    end
    require 'ruhoh/plugins/local_plugins_plugin'

    Ruhoh::Plugins::Plugin.run_all self

    Silly::UrlSlug.add_extensions(Ruhoh::Converter.extensions)
  end

  def env
    @env || 'development'
  end

  def compiled_path(url)
    if config['compile_as_root']
      url = url.gsub(/^#{ config.base_path.chomp('/') }\/?/, '')
    end

    path = File.expand_path(File.join(config['compiled_path'], url)).gsub(/\/{2,}/, '/')
    CGI.unescape(path)
  end

  # Always remove trailing slash.
  # Returns String - normalized url with prepended base_path
  def to_url(*args)
    url = config.base_path + args.join('/')
    url = url.gsub(/\/{2,}/, '/')
    (url == "/") ? url : url.chomp('/')
  end

  def relative_path(filename)
    filename.gsub(Regexp.new("^#{@base}/"), '')
  end

  def compiled_path_page(url)
    path = compiled_path(url)
    path = "index.html" if path.empty?
    path += '/index.html' unless path =~ /\.\w+$/
    path
  end

  # Compile the ruhoh instance (save to disk).
  # Note: This method recursively removes the target directory. Should there be a warning?
  #
  # Extending:
  #   TODO: Deprecate this functionality and come up with a 2.0-friendly interface.
  #   The Compiler module is a namespace for all compile "tasks".
  #   A "task" is a ruby Class that accepts @ruhoh instance via initialize.
  #   At compile time all classes in the Ruhoh::Compiler namespace are initialized and run.
  #   To add your own compile task simply namespace a class under Ruhoh::Compiler
  #   and provide initialize and run methods:
  #
  #  class Ruhoh
  #    module Compiler
  #      class CustomTask
  #        def initialize(ruhoh)
  #          @ruhoh = ruhoh
  #        end
  #       
  #        def run
  #          # do something here
  #        end
  #      end
  #    end
  #  end
  def compile
    Ruhoh::Friend.say { plain "Compiling for environment: '#{@env}'" }
    FileUtils.rm_r config['compiled_path'] if File.exist?(config['compiled_path'])
    FileUtils.mkdir_p config['compiled_path']

    compilers = query.list
    # Hack to ensure assets are processed first so post-processing logic reflects in the templates.
    if compilers.include?('stylesheets')
      compilers.delete('stylesheets')
      compilers.unshift('stylesheets')
    end

    if compilers.include?('javascripts')
      compilers.delete('javascripts')
      compilers.unshift('javascripts')
    end

    compilers.each do |name|
      use = config.collection(name)["use"] || name

      next if ["ignore", "layouts", "partials", "data", "theme"].include?(use)

      # TODO: Improve this manual override.
      if ["javascripts", "stylesheets"].include?(use)
        use = "asset"
      end

      compiler = collections.compiler(use)
      compiler ||= collections.compiler("pages")

      compiler.new(self).run(name)
    end

    # Run extra compiler tasks if available:
    if Ruhoh.const_defined?(:Compiler)
      Ruhoh::Compiler.constants.each {|c|
        compiler = Ruhoh::Compiler.const_get(c)
        next unless compiler.respond_to?(:new)
        task = compiler.new(self)
        next unless task.respond_to?(:run)
        task.run
      }
    end

    true
  end
end
