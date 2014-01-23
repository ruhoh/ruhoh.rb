require 'ruhoh/collections/collectable'

class Ruhoh::Collections
  # Load all the collections
  FileUtils.cd(path = File.dirname(__FILE__)) do
    (Dir['*.rb'] + Dir[File.join('*', '*.rb')]).sort.each do |f|
      require File.join(path, f)
    end
  end

  Special = %w{ javascripts stylesheets theme widgets }

  def initialize(ruhoh)
    @ruhoh = ruhoh
    @collections = {}
  end

  # Load and cache a given collection.
  # This allows you to work with single object instance and perform
  # persistant mutations on it if necessary.
  # Note the collection is always wrapped in its view.
  # @returns[Class Instance] of the resource and class_name given.
  def load(name)
    name = name.to_s
    return @collections[name] if @collections[name]

    #TODO: Optimize this.
    # at the least, the item's parent collection should return
    config = @ruhoh.config.collection(name)

    query = @ruhoh.query
    # Handle special "_root" case
    # TODO: Remove hard-coded stuff
    if (name == "_root")
      special_files = %w(config Gemfile publish page_not_found dashboard data)
      query = query.path("").where("$shortname" => { "$nin" => special_files })
    else
      query = query.path_all(name)
    end

    query = query.sort(config["sort"]) if config["sort"]
    query = query.published
    pages = query.to_a #TODO: FIX THIS

    use = config["use"]

    unless use
      use = pages.empty? ? name : pages.first.model
      use = Special.include?(use) ? use : "pages"
    end

    namespace = get_namespace(use)
    modelView = (namespace && namespace.const_defined?(:ModelView)) ?
                   namespace.const_get(:ModelView) :
                   nil
    collectionView = (namespace && namespace.const_defined?(:CollectionView)) ?
                      namespace.const_get(:CollectionView) :
                      nil

    pages = pages.map{ |a| modelView ? modelView.new(a, @ruhoh) : a }

    @collections[name] = collectionView ? collectionView.new(pages, @ruhoh) : Silly::Collection.new(pages)
    @collections[name].collection_name = name

    @collections[name]
  end

  def model_view(use)
    namespace = get_namespace(use)

    (namespace && namespace.const_defined?(:ModelView)) ?
      namespace.const_get(:ModelView) :
      nil
  end

  def compiler(use)
    namespace = get_namespace(use)

    (namespace && namespace.const_defined?(:Compiler)) ?
      namespace.const_get(:Compiler) :
      nil
  rescue NameError
    nil
  end

  private

  def get_namespace(name)
    name = camelize(name)
    Ruhoh::Collections.const_defined?(name) ?
      Ruhoh::Collections.const_get(name) :
      nil
  end

  def camelize(name)
    name.to_s.split('_').map { |a| a.capitalize }.join
  end
end
