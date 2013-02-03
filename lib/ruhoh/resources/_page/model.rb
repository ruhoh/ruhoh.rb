module Ruhoh::Resources::Page
  class Model < Ruhoh::Resources::Base::Model

    FMregex = /^(---\s*\n.*?\n?)^(---\s*$\n?)/m
    DateMatcher = /^(.+\/)*(\d+-\d+-\d+)-(.*)(\.[^.]+)$/
    Matcher = /^(.+\/)*(.*)(\.[^.]+)$/

    def content
      self.parse_page_file['content']
    end

    def parse_page_file
      raise "File not found: #{@pointer['realpath']}" unless File.exist?(@pointer['realpath'])

      page = File.open(@pointer['realpath'], 'r:UTF-8') {|f| f.read }

      front_matter = page.match(FMregex)
      if front_matter
        data = YAML.load(front_matter[0].gsub(/---\n/, "")) || {}
      else
        data = {}
      end

      {
        "data" => data,
        "content" => page.gsub(FMregex, '')
      }
    rescue Psych::SyntaxError => e
      Ruhoh.log.error("ERROR in #{path}: #{e.message}")
      nil
    end

    def formatted_date(date)
      Time.parse(date.to_s).strftime('%Y-%m-%d')
    rescue
      false
    end

    def parse_page_filename(filename)
      data = *filename.match(DateMatcher)
      data = *filename.match(Matcher) if data.empty?
      return {} if data.empty?

      if filename =~ DateMatcher
        {
          "path" => data[1],
          "date" => data[2],
          "slug" => data[3],
          "title" => self.to_title(data[3]),
          "extension" => data[4]
        }
      else
        {
          "path" => data[1],
          "slug" => data[2],
          "title" => self.to_title(data[2]),
          "extension" => data[3]
        }
      end
    end

    # my-post-title ===> My Post Title
    def to_title(file_slug)
      file_slug.gsub(/[^\p{Word}+]/u, ' ').gsub(/\b\w/){$&.upcase}
    end

    # Another blatently stolen method from Jekyll
    # The category is only the first one if multiple categories exist.
    def permalink(post)
      format = post['permalink'] || config['permalink']
      if format && format.include?(':')
        date = Date.parse(post['date']) rescue nil
        title = Ruhoh::Utils.to_url_slug(post['title'])
        filename = File.basename(post['id'], File.extname(post['id']))
        category = Array(post['categories'])[0]
        category = category.split('/').map {|c| Ruhoh::Utils.to_url_slug(c) }.join('/') if category

        url = {
          "year"       => date.strftime("%Y"),
          "month"      => date.strftime("%m"),
          "day"        => date.strftime("%d"),
          "title"      => title,
          "filename"   => filename,
          "i_day"      => date.strftime("%d").to_i.to_s,
          "i_month"    => date.strftime("%m").to_i.to_s,
          "categories" => category || '',
        }.inject(format) { |result, token|
          result.gsub(/:#{Regexp.escape token.first}/, token.last)
        }.gsub(/\/+/, "/")
      elsif format
        # Use the literal permalink if it is a non-tokenized string.
        url = format.gsub(/^\//, '').split('/').map {|p| CGI::escape(p) }.join('/')
      else
        # Use the filepath.
        # Only recognize extensions registered from a 'convertable' module.
        # This means 'non-convertable' extensions should pass-through.
        ext = File.extname(post['id'])
        name = post['id'].gsub(Regexp.new("#{ext}$"), '')
        ext = '.html' if Ruhoh::Converter.extensions.include?(ext)
        url = name.split('/').map {|p| Ruhoh::Utils.to_url_slug(p) }.join('/')
        url = "#{url}#{ext}".gsub(/index.html$/, '')
        unless (post['permalink'] == 'preserve' || config['permalink'] == 'preserve')
          url = url.gsub(/\.html$/, '')
        end
      end

      url = '/' if url.empty?

      @ruhoh.to_url(url)
    end

  end
end