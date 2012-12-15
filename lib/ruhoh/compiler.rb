class Ruhoh
  
  # The Compiler module is a namespace for all compile "tasks".
  # A "task" is a ruby Class that accepts @ruhoh instance via initialize.
  # At compile time all classes in the Ruhoh::Compiler namespace
  # are initialized and run.
  # To add your own compile task simply namespace it under Ruhoh::Compiler
  # and provide initialize and run methods:
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
  module Compiler

    # TODO: seems rather dangerous to delete the incoming target directory?
    def self.compile(ruhoh)
      Ruhoh::Friend.say { plain "Compiling for environment: '#{ruhoh.env}'" }
      FileUtils.rm_r ruhoh.paths.compiled if File.exist?(ruhoh.paths.compiled)
      FileUtils.mkdir_p ruhoh.paths.compiled
      
      # Run the resource compilers
      ruhoh.resources.all.keys.each do |name|
        next unless ruhoh.resources.compiler?(name)
        ruhoh.resources.load_compiler(name).run
      end
      
      # Run extra compiler tasks
      Ruhoh::Compiler.constants.each {|c|
        compiler = Ruhoh::Compiler.const_get(c)
        next unless compiler.respond_to?(:new)
        task = compiler.new(ruhoh)
        next unless task.respond_to?(:run)
        task.run
      }
      true
    end
    
  end
end