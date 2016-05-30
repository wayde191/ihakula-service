require 'rubygems'
require 'bundler'
require 'grape'
require './app/application'
require 'rack/cors'
require './app/transaction_logger'
require './app/settings_loader'

use Rack::Cors do
  allow do
    origins '*'
    resource '*', headers: :any, methods: [:get, :post, :put, :delete, :options]
  end
end

use Rack::Static,
    :urls => %w(/images /lib /css),
    :root => 'public'

run Rack::Cascade.new [IHakula::Application,
                       lambda { |env|
                         [200,
                          {'Content-Type' => 'text/html', 'Cache-Control' => 'public, max-age=86400'},
                          File.open('public/index.html', File::RDONLY)
                         ]
                       }]