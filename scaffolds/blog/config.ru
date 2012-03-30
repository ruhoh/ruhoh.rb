require 'rack'
require 'ruhoh'

Ruhoh.setup

use Rack::Lint
use Rack::ShowExceptions
use Rack::Static, {:urls => ["/#{Ruhoh.folders.media}", "/#{Ruhoh.folders.templates}"]}
run Ruhoh::Previewer.new