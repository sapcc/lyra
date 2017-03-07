require 'rack'
require 'prometheus/client/rack/exporter'

app = Proc.new do |env|
  ['200', {'Content-Type' => 'text/html'}, ['<html><head><title>Que metrics</title></head><body><a href="/metrics">metrics</a></body></html>']]
end

schmapp = Prometheus::Client::Rack::Exporter.new(app)
Thread.new do
  Rack::Handler::WEBrick.run(schmapp, :Host => '0.0.0.0', :Port => ENV.fetch('EXPORTER_PORT', 9100).to_i)
end

require_relative 'environment.rb'
