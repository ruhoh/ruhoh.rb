module Ruhoh::Resources::Widgets
  class Compiler
    include Ruhoh::Base::Compilable

    def run
      return unless setup_compilable

      files = @collection.files.values
      files.delete_if { |p| !is_valid_file? (p['id']) }

      files.each do |pointer|
        compiled_file = File.join(@collection.compiled_path, pointer['id'])
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
