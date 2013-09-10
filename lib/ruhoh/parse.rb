class Ruhoh
  module Parse
    TopYAMLregex = /^(---\s*\n.*?\n?)^(---\s*$\n?)/m
    TopJSONregex = /^({\s*\n.*?\n?)^(}\s*$\n?)/m

    # Primary method to parse the file as a page-like object.
    # File API is currently defines:
    #   1. Top meta-data
    #   2. Page Body
    #
    # @returns[Hash Object] processed top meta-data, raw (unconverted) content body
    def self.page_file(filepath)
      result = {}
      front_matter = nil
      format = nil
      page = File.open(filepath, 'r:UTF-8') { |f| f.read }
      first_line = page.lines.first

      begin
        if (first_line.strip == '---')
          front_matter = page.match(TopYAMLregex)
          format = 'yaml'
       elsif (first_line.strip == '{')
          front_matter = page.match(TopJSONregex)
          format = 'json'
        end
      rescue => e
        raise "Error trying to read meta-data from #{ filepath }." +
        " Check your folder configuration.  Error details: #{e}"
      end

      if format == 'yaml'
        data = yaml_for_pages(front_matter, filepath)
        result["content"] = page.gsub(TopYAMLregex, '')
      else
        data = json_for_pages(front_matter, filepath)
        result["content"] = page.gsub(TopJSONregex, '')
      end

      result["data"] = data
      result
    end

    def self.data_file(*args)
      base = File.__send__(:join, args)

      filepath = nil
      ["#{ base }.json", "#{ base }.yml", "#{ base }.yaml"].each do |result|
        filepath = result and break if File.exist?(result)
      end
      return nil unless filepath

      file = File.open(filepath, 'r:UTF-8') { |f| f.read }

      File.extname(filepath) == ".json" ? json(file) : yaml(file)
    end

    def self.yaml(file)
      puts "YAML parser"
      YAML.load(file) || {}
    rescue Psych::SyntaxError => e
      Ruhoh.log.error("ERROR in #{filepath}: #{e.message}")
      nil
    end

    def self.json(file)
      puts "JSON parser"
      JSON.load(file) || {}
    end

    def self.yaml_for_pages(front_matter, filepath)
      puts "YAML frontmatter"
      return {} unless front_matter
      YAML.load(front_matter[0].gsub(/---\n/, "")) || {}
    rescue Psych::SyntaxError => e
      Ruhoh.log.error("Psych::SyntaxError while parsing top YAML Metadata in #{ filepath }\n" +
        "#{ e.message }\n" +
        "Try validating the YAML metadata using http://yamllint.com"
      )
      nil
    end

    def self.json_for_pages(front_matter, filepath)
      puts "JSON frontmatter"
      return {} unless front_matter
      JSON.load(front_matter[0]) || {}
    end
  end
end