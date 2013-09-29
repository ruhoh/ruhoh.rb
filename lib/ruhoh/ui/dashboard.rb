class Ruhoh::UI::Dashboard
  def initialize(ruhoh)
    @ruhoh = ruhoh
  end

  def call(env)
    path = @ruhoh.cascade.find_file('dashboard')['realpath']
    template = File.open(path, 'r:UTF-8').read
    view = @ruhoh.master_view({"content" => template })

    [200, {'Content-Type' => 'text/html'}, [ view.content ]]
  end
end
