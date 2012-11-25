module Ruhoh::Resources::Pages
  class Collection < Ruhoh::Resources::Base::Collection
    def config
      hash = super
      hash['layout'] ||= 'page'
      hash['exclude'] = Array(hash['exclude']).map {|node| Regexp.new(node) }
      hash
    end
    
    def compile(id=nil)
      datas = if id
        [ @ruhoh.db.__send__(self.namespace)[id] ].compact
      else
        @ruhoh.db.__send__(self.namespace).each_value
      end

      datas.each do |data|
        model.new(self, data["pointer"]).compile
      end

      nil
    end
  end
end