shared_context 'write_default_theme' do
  before(:each) do
    Dir.mkdir SampleSitePath
    theme = "twitter"
    # Create base config.yml + base theme
    File.open(File.join(SampleSitePath, Ruhoh.names.config_data), "w+") { |file|
      file.puts <<-TEXT
---
theme: '#{theme}'
---  
  TEXT
    }
    theme_dir = File.join(SampleSitePath, Ruhoh.names.themes, theme)
    FileUtils.makedirs theme_dir
  end
end

shared_context 'default_setup' do
  before(:each) do
    Ruhoh.setup(:source => SampleSitePath)
    Ruhoh.setup_paths
    Ruhoh.setup_urls
  end
end
