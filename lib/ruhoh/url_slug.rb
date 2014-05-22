class Ruhoh
  class UrlSlug
    def initialize(opts)
      @page_data = opts[:page_data]
      @format = opts[:format]
      @pointer = @page_data["pointer"]
    end

    # @return[String] URL Slug based on the given data and format.
    def generate
      url = @format.include?(':') ? dynamic : literal
      url = process_url_extension(url)
      url.empty? ? '/' : url
    end 

    # @return[String] the literal URL without token substitution.
    def literal
      @format.gsub(/^\//, '').split('/').map {|p| CGI::escape(p) }.join('/')
    end

    # @return[String] the dynamic URL with token substitution.
    def dynamic
      cache = data
      result = @format
                .gsub(/:[^\/\.-]+/) { |a| cache[$&.gsub(':', '')] }
                .gsub('//', '/')
                .split('/')

      # this is ugly but I'm out of ideas. Help!
      last = result.pop
      if uses_extension?
        last = last
                .split('.')
                .map{ |a| Ruhoh::StringFormat.clean_slug_and_escape(a) }
                .join('.')
      else
        last = Ruhoh::StringFormat.clean_slug_and_escape(last)
      end

      result
        .map{ |a| Ruhoh::StringFormat.clean_slug_and_escape(a) }
        .join('/') + "/#{ last }"
    end

    def data
      result = @page_data
      result = result.merge(date_data) if uses_date?

      result.merge({
        "filename"          => filename,
        "path"              => path,
        "relative_path"     => relative_path,
        "categories"        => category,
      })
    end

    def date_data
      date = Time.parse(@page_data['date'].to_s)

      {
        "year"       => date.strftime("%Y"),
        "month"      => date.strftime("%m"),
        "day"        => date.strftime("%d"),
        "i_day"      => date.strftime("%d").to_i.to_s,
        "i_month"    => date.strftime("%m").to_i.to_s,
      }
    rescue ArgumentError, TypeError
      Ruhoh.log.error(
        "ArgumentError:" +
        " The file '#{ @pointer["realpath"] }' has a permalink '#{ @format }'" +
        " which is date dependant but the date '#{ @page_data['date'] }' could not be parsed." +
        " Ensure the date's format is: 'YYYY-MM-DD'"
      )
    end

    def filename
      File.basename(@page_data['id'], ext)
    end

    def ext
      File.extname(@page_data['id'])
    end

    # Category is only the first one if multiple categories exist.
    def category
      string = Array(@page_data['categories'])[0]
      return '' if string.to_s.empty?

      string.split('/').map { |c|
        Ruhoh::StringFormat.clean_slug_and_escape(c)
      }.join('/')
    end

    def relative_path
      string = File.dirname(@page_data['id'])
      (string == ".") ? "" : string
    end

    def path
      File.join(@pointer["resource"], relative_path)
    end

    private

    def uses_date?
      result = false
      %w{ :year :month :day :i_day :i_month }.each do |token|
        if @format.include?(token)
          result = true
          break
        end
      end

      result
    end

    # Is an extension explicitly defined?
    def uses_extension?
      @format =~ /\.[^\.]+$/
    end

    # The url extension depends on multiple factors: 
    # user-config   : preserve any extension set by the user in the format.
    # converters    : Automatically change convertable extensions to .html
    #                 Non-convertable file-extensions should 'pass-through' 
    # 'pretty'      : Automatically prettify urls (omit .html) unless user disabled.
    #
    # @return[String]
    def process_url_extension(url)
      return url if uses_extension?

      url += Ruhoh::Converter.extensions.include?(ext) ? '.html' : ext

      # Prettify by default
      @page_data['permalink_ext'] ?
        url :
        url.gsub(/index|index.html$/, '').gsub(/\.html$/, '')
    end
  end
end
