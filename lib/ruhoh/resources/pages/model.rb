module Ruhoh::Resources::Pages
  class Model < Ruhoh::Base::Page::Model
    # Generate this filepath
    # Returns data to be registered to the database
    def generate
      parsed_page     = parse_page_file
      data            = parsed_page['data']
      data['pointer'] = @pointer
      data['id']      = @pointer['id']
      data['url']     = permalink(data)
      data['title']   = data['title'] || to_title
      data['layout']  = config['layout'] if data['layout'].nil?

      # Register this route for the previewer
      @ruhoh.db.routes[data['url']] = @pointer

      {
        "#{@pointer['id']}" => data
      }
    end

    def to_title
      name = File.basename( @pointer['id'], File.extname(@pointer['id']) )
      name = @pointer['id'].split('/')[-2] if name == 'index' && !@pointer['id'].index('/').nil?
      name.gsub(/[^\p{Word}+]/u, ' ').gsub(/\b\w/){$&.upcase}
    end
  end
end