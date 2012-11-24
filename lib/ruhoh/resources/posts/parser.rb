module Ruhoh::Resources::Posts
  class Parser < Ruhoh::Resources::Resource
    def config
      hash = super
      hash['permalink'] ||= "/:categories/:year/:month/:day/:title.html"
      hash['layout'] ||= 'post'
      hash['summary_lines'] ||= 20
      hash['summary_lines'] = hash['summary_lines'].to_i
      hash['latest'] ||= 2
      hash['latest'] = hash['latest'].to_i
      hash['rss_limit'] ||= 20
      hash['rss_limit'] = hash['rss_limit'].to_i
      hash['exclude'] = Array(hash['exclude']).map {|node| Regexp.new(node) }
      hash
    end
  end
end