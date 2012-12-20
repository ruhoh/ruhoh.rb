module Ruhoh::Resources::Pages
  class Collection < Ruhoh::Resources::Base::Collection
    def config
      hash = super
      hash['layout'] ||= 'page'
      hash['exclude'] = Array(hash['exclude']).map {|node| Regexp.new(node) }
      hash['ext'] ||= ".md"
      hash
    end
  end
end