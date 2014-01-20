module Ruhoh::Views
  # Mixin to provide a reusable interface to ruhoh and collections in the view context.
  # It makes calling collections directly by their name possible.
  #
  #  Example:
  #   pages.all.each{ |page| }
  #
  # The mixin allows to import the interface into different view engines.
  # Mustache is used as the default but Haml and ERB are also supported.
  module Context
    def self.included(klass)
      klass.__send__(:attr_accessor, :content)
    end

    def initialize(opts)
      @ruhoh = opts[:ruhoh]
      @item = opts[:item]
      @content = opts[:content]
    end

    # Delegate #page to the kind of resource this view is modeling.
    def page
      @item
    end

    def collection
      page.collection.master = self
      page.collection
    end

    # NOTE: newline ensures proper markdown rendering.
    # TODO: need to query on optional extension: be watermelon or watermelon.html
    def partial(name)
      name = name.to_s
      # TODO FIX THIS IT NEEDS TO WORK WITH full ids but no ext.
      name = File.basename(name, File.extname(name))
      partial = @ruhoh.collections.load("partials").find{ |a| name == a.shortname }
      partial ?
        partial.content.to_s + "\n" :
        Ruhoh::Friend.say { yellow "partial not found: '#{name}'" } 
    end

    def urls
      {
        'base_path' => @ruhoh.config.base_path,
        'production' => @ruhoh.config["production_url"],
        'production_url' => @ruhoh.config["production_url"]
      }
    end

    # Internal API methods
    # --------------------------------------------------------------------------

    def get_binding
      binding
    end

    def resolve_collection(name, args)
      return false unless collection_exists?(name)

      string = name.to_s.gsub(/^to_/, '')
      if name.to_s =~ /^to_/
        resource_generator_for(string, args)
      else
        load_collection_view_for(string)
        @ruhoh.collections.load(string)
      end
    end

    # Can be either the name or to_collection_name
    def collection_exists?(collection_name)
      string = collection_name.to_s.gsub(/^to_/, '')
      @ruhoh.query.list.include?(string)
    end

    # Load collection views dynamically when calling a collection name.
    # @returns[CollectionView] for the calling resource.
    def load_collection_view_for(collection_name)
      view = @ruhoh.collections.load(collection_name)
      view.master = self
      view
    end

    # Transforms an Array or String of item ids into corresponding item objects.
    # Implements 'to_<resource>` contextual helper.
    # @returns[Array] the resource modelView objects or raw data hash.
    def resource_generator_for(collection_name, sub_context)
      Array(sub_context).map { |id|
        load_collection_view_for(collection_name).find{ |a|
          a.id == File.join(collection_name, id)
        }
      }.compact
    end

    def method_missing(name, *args, &block)
      if(response = resolve_collection(name, args))
        response
      else
        super
      end
    end

    def respond_to?(method)
      collection_exists?(method) ? true : super
    end
  end
end
