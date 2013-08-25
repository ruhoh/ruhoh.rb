class Ruhoh
  # StringFormat is meant to expose the common (public) interface
  # for where strings (namely URLS) are formatted.
  # Users are encouraged to reimplement these methods via plugins to enable
  # custom-defined slug generation logic based on their tastes. 
  #
  # TODO: 
  #   - Natively support the most popular slug formats.
  #   - Better support for Internationalization.
  module StringFormat

    # Public interface for building 'clean slugs'
    # Redefine this method to implement custom slug generation.
    def self.clean_slug(string)
      hyphenate(string)
    end

    def self.clean_slug_and_escape(string)
      CGI::escape(clean_slug(string))
    end

    # Simple url slug normalization.
    # Converts all non word characters into hyphens.
    # This may not be what you want so feel free to overwite the public
    # method in place of another formatter.
    #
    # Ex: My Post Title ===> my-post-title
    def self.hyphenate(string)
      string = string.to_s.downcase.strip.gsub(/[^\p{Word}+]/u, '-')
      string.gsub(/^\-+/, '').gsub(/\-+$/, '').gsub(/\-+/, '-')
    end

    # TODO: Probably use ActiveSupport for this stuff
    # Ex: my-post-title ===> My Post Title
    def self.titleize(string)
      string.gsub(/[^\p{Word}+]/u, ' ').gsub(/\b\w/){ $&.upcase }
    end

    # Convert CamelCase to snake_case
    # Thanks ActiveSupport: http://stackoverflow.com/a/1509939/101940
    def self.snake_case(string)
      string.
      to_s.
      gsub(/::/, '/').
      gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
      gsub(/([a-z\d])([A-Z])/,'\1_\2').
      tr("-", "_").
      downcase
    end
  end
end
