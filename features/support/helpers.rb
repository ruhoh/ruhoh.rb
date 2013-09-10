# Full path to mock blog directory
SampleSitePath = File.expand_path(File.join(File.dirname(__FILE__), '..', '..', '__tmp'))

def start
  @ruhoh = Ruhoh.new
  @ruhoh.setup(:source => SampleSitePath)
  @ruhoh.env = :test
  @ruhoh.setup_paths
  @ruhoh.setup_plugins
end

def compile
  start
  @ruhoh.env = 'production'
  @ruhoh.paths.compiled = File.join(SampleSitePath, 'compiled')
  @ruhoh.compile
end

def make_config(data)
  path = File.join(SampleSitePath, "config.yml")
  File.open(path, "w+") { |file|
    file.puts data.to_yaml
  }
end

def make_file(opts)
  path = File.join(SampleSitePath, opts[:path])
  FileUtils.mkdir_p(File.dirname(path))

  data = opts[:data] || {}
  if data['categories']
    data['categories'] = data['categories'].to_s.split(',').map(&:strip)
  end
  if data['tags']
    data['tags'] = data['tags'].to_s.split(',').map(&:strip)
    puts "tags #{data['tags']}"
  end
  data.delete('layout') if data['layout'].to_s.strip.empty?

  metadata = data.empty? ? '' : data.to_yaml.to_s + "\n---\n"

  File.open(path, "w+") { |file|
    if metadata.empty?
      file.puts <<-TEXT
#{ opts[:body] }
TEXT
    else
      file.puts <<-TEXT
#{ metadata }

#{ opts[:body] }
TEXT
    end
  }
end

def get_compiled_file(path)
  FileUtils.cd(@ruhoh.paths.compiled) {
    File.open(path, 'r:UTF-8') { |f| 
      return f.read }
  }
end

def this_compiled_file
  unless @filepath
    raise "Your step definition is trying to reference 'this' compiled file" +
          " but you haven't provided a file reference." +
          " This probably just means using 'my compiled site should have the file \"sample.md\"' first."
  end
  get_compiled_file(@filepath)
end

Before do
  FileUtils.remove_dir(SampleSitePath,1) if Dir.exists? SampleSitePath
  Dir.mkdir SampleSitePath
end

After do
  FileUtils.remove_dir(SampleSitePath,1) if Dir.exists? SampleSitePath
end