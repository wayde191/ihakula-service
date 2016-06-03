require 'ostruct'
require_relative '../app/log_wrapper'
require_relative '../app/log_formatter'

class TransactionLogger

  def initialize(app)
    Thread.current[:transaction_id] = SecureRandom::uuid
    @app = app
    settings = SettingsLoader::load_settings('./config.yml')
    @logger = LogWrapper.new(OpenStruct.new({log_path: settings['log_path']}), LogFormatter.new)
  end

  def call(env)
    rack_request_new = Rack::Request.new(env)
    @logger.request_details(rack_request_new)

    status, headers, response = @app.call(env)

    @logger.response_details(response, status, headers)
    [status, headers, response]
  end
end