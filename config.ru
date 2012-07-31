require 'bundler'
Bundler.require

STDOUT.sync = true

#use Rack::Typekit, :kit => "nlj2rqt"
use Rack::TryStatic,
    :root => "_site",
    :urls => %w[/],
    :try => ['.html', 'index.html', '/index.html']

run lambda { [200, {'Content-Type' => 'text/html'}, ['Not Found']]}
