require 'bundler'
Bundler.require

STDOUT.sync = true

use Rack::Static, urls: ["/css", "/images", "/js", "favicon.ico"], root: "."
use Rack::TryStatic,
    :root => "_site",
    :urls => %w[/],
    :try => ['.html', 'index.html', '/index.html']

run lambda { [404, {'Content-Type' => 'text/html'}, ['Not Found']]}
