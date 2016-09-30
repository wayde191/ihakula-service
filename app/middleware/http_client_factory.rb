require_relative 'http_client'
require_relative '../../app/log_wrapper'
require_relative '../../app/log_formatter'

class HttpClientFactory
  def self.create(settings)
    log_wrapper = LogWrapper.new(settings, LogFormatter.new)
    HTTPClient.new(log_wrapper)
  end
end