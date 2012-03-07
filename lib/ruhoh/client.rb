class Ruhoh
  
  module Client
    Root = File.expand_path(File.join(File.dirname(__FILE__), '../..'))

    def self.new_blog(name)
      if name.nil?
        puts "Name must be specified"
        exit 0
      end

      source_directory = File.join(Root, 'scaffolds/blog')
      target_directory = File.join(Dir.pwd, name)

      if File.exist?(target_directory)
        puts "#{target_directory} already exists. Specify another directory."
        exit 0
      end

      FileUtils.mkdir target_directory
      FileUtils.cp_r "#{source_directory}/.", target_directory
      
      puts "=> Blog successfully cloned to:"
      puts "=> #{target_directory}"
    end
  end
  
end #Ruhoh