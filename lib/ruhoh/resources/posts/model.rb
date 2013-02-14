module Ruhoh::Resources::Posts
  class Model < Ruhoh::Base::Page::Model
    def generate
      parsed_page = parse_page_file
      data = parsed_page['data']

      filename_data = parse_page_filename(@pointer['id'])

      data['date'] ||= filename_data['date']
      data['pointer']       = @pointer
      data['id']            = @pointer['id']
      data['date']          = data['date'].to_s
      data['title']         = data['title'] || filename_data['title']
      data['url']           = self.permalink(data)
      data['categories']    = Array(data['categories'])
      data['tags']          = Array(data['tags'])
      data['layout']  = config['layout'] if data['layout'].nil?

      # Register this route for the previewer
      @ruhoh.db.routes[data['url']] = @pointer

      {
        "#{@pointer['id']}" => data
      }
    end
  end
end