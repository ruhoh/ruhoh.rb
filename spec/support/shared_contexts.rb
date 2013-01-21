shared_context 'write_default_theme' do
  before(:each) do
    Dir.mkdir SampleSitePath
    theme = "twitter"
    # Create base config.yml + base theme
    File.open(File.join(SampleSitePath, "config.yml"), "w+") { |file|
      file.puts <<-TEXT
---
theme: '#{theme}'
---  
  TEXT
    }
    theme_dir = File.join(SampleSitePath, theme)
    FileUtils.makedirs theme_dir
  end
end

shared_context 'default_setup' do
  before(:each) do
    @ruhoh = Ruhoh.new
    @ruhoh.setup(:source => SampleSitePath)
    @ruhoh.setup_paths
    @ruhoh.setup_urls
  end
end
