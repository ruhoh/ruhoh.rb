require 'ruhoh/base/routable'
module Ruhoh::Resources::Pages
  class Collection
    include Ruhoh::Base::Collectable
    include Ruhoh::Base::Routable

    # model observer callback.
    def update(model_data)
      routes_add(model_data['data']['url'], model_data['data']['pointer'])
      @ruhoh.cache.set(model_data['data']['pointer']['realpath'], model_data)
    end

    # Easy way to regenerate a model
    # Used in the file watcher implementation.
    def touch(name_or_pointer)
      pointer = find_file(name_or_pointer)
      routes_delete(pointer)
      find(name_or_pointer) # find/load so the route is regenerated
    end

    def config
      hash = super
      hash['permalink'] ||= "/:path/:filename"
      hash['summary_lines'] ||= 20
      hash['summary_lines'] = hash['summary_lines'].to_i
      hash['summary_stop_at_header'] ||= false
      hash['latest'] ||= 2
      hash['latest'] = hash['latest'].to_i
      hash['ext'] ||= ".md"

      rss = hash['rss'] || {}
      rss['limit'] ||= 20
      rss['limit'] = rss['limit'].to_i
      rss["url"] ||=  "/#{ resource_name }"
      rss["url"] = rss["url"].to_s
      rss["url"] = "/#{ rss["url"] }" unless rss["url"].start_with?('/')
      rss["url"] = rss["url"].chomp('/') unless rss["url"] == '/'
      hash['rss'] = rss

      paginator = hash['paginator'] || {}
      paginator["url"] ||=  "/#{ resource_name }/index"
      paginator["url"] = paginator["url"].to_s
      unless paginator["url"].start_with?('/')
        paginator["url"] = "/#{paginator["url"]}"
      end
      unless paginator["url"] == '/'
        paginator["url"] = paginator["url"].chomp('/') 
      end

      paginator["per_page"] ||=  5
      paginator["per_page"] = paginator["per_page"].to_i
      paginator["layout"] ||=  "paginator"

      if paginator["root_page"]
        unless paginator["root_page"].start_with?('/')
          paginator["root_page"] = "/#{paginator["root_page"]}"
        end
        unless paginator["root_page"] == '/'
          paginator["root_page"] = paginator["root_page"].chomp('/')
        end
      end

      hash['paginator'] = paginator

      hash
    end
  end
end
