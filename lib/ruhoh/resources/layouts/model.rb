module Ruhoh::Resources::Layouts
  class Model < Ruhoh::Base::Model

    def process
      parse_layout_file(@pointer['realpath'])
    end

    private

    def parse_layout_file(*args)
      path = File.__send__(:join, args)
      raise "Layout file not found: #{path}" unless File.exist?(path)
      data = {}
      page = File.open(path, 'r:UTF-8') {|f| f.read }

      front_matter = page.match(Ruhoh::Utils::FMregex)
      if front_matter
        data = YAML.load(front_matter[0].gsub(/---\n/, "")) || {}
      end
      
      data['pointer'] = @pointer
      data['id'] = @pointer['id']
      
      a = { 
        "data" => data,
        "content" => page.gsub(Ruhoh::Utils::FMregex, '')
      }

      @data = data
      @content = a['content']

      a
    rescue Psych::SyntaxError => e
      Ruhoh.log.error("ERROR in #{path}: #{e.message}")
      nil
    end
  end
end