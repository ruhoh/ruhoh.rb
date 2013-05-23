module Ruhoh::Resources::Widgets
  class Compiler
    include Ruhoh::Base::Compilable

    def run
      collection = @collection
      unless @collection.paths?
        Ruhoh::Friend.say { yellow "#{collection.resource_name.capitalize}: directory not found - skipping." }
        return
      end
      Ruhoh::Friend.say { cyan "#{collection.resource_name.capitalize}: (copying valid files)" }

      compiled_path = Ruhoh::Utils.url_to_path(@ruhoh.to_url(@collection.url_endpoint), @ruhoh.paths.compiled)
      FileUtils.mkdir_p compiled_path

      files = collection.files.values
      files.delete_if { |p| !is_valid_file? (p['id']) }

      files.each do |pointer|
        compiled_file = File.join(compiled_path, pointer['id'])
        FileUtils.mkdir_p File.dirname(compiled_file)
        FileUtils.cp_r pointer['realpath'], compiled_file
        Ruhoh::Friend.say { green "  > #{pointer['id']}" }
      end
    end

    def is_valid_file?(filepath)
      return false if filepath.end_with?('.html')

      collection.widgets.each do |name|
        widget_config = collection.config[name] || {}

        model = collection.find("#{ name }/#{ (widget_config['use'] || "default") }")
        next unless model

        excludes = Array(model.data['exclude']).map { |node| Regexp.new(node) }
        excludes.each { |regex| return false if filepath =~ regex }
      end

      true
    end
  end
end
