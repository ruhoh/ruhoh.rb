module Ruhoh::Base::Compilable
  def self.included(klass)
    __send__(:attr_reader, :collection)
  end

  def initialize(collection)
    @ruhoh = collection.ruhoh
    @collection = collection
  end

  def setup_compilable
    return false unless collection_exists?

    compile_collection_path
  end

  def compile_collection_path
    FileUtils.mkdir_p(@collection.compiled_path)
  end

  def collection_exists?
    collection = @collection
    unless @collection.paths?
      Ruhoh::Friend.say { yellow "#{ collection.resource_name.capitalize }: directory not found - skipping." }
      return false
    end
    Ruhoh::Friend.say { cyan "#{ collection.resource_name.capitalize }: (copying valid files)" }
    true
  end
end
