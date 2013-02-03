module Ruhoh::Resources::Posts
  class Model < Ruhoh::Resources::Page::Model
    
    def generate
      parsed_page = self.parse_page_file
      data = parsed_page['data']

      filename_data = self.parse_page_filename(@pointer['id'])
      if filename_data.empty?
        #error = "Invalid Filename Format. Format should be: my-post-title.ext"
        #invalid << [@pointer['id'], error] ; next
      end

      data['date'] ||= filename_data['date']

      unless self.formatted_date(data['date'])
        #error = "Invalid Date Format. Date should be: YYYY-MM-DD"
        #invalid << [@pointer['id'], error] ; next
      end

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