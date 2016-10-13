require 'json'

require_relative '../../app/exceptions/ihakula_service_error'

class WeixinStore

  def initialize(app_settings)
    @settings = app_settings
    @logger = LogWrapper.new(app_settings, LogFormatter.new)
  end

  def get_validated_neighbours
    begin
      '<xml>hello</xml>'
    rescue StandardError => ex
      raise IhakulaServiceError, ex.message
    end
  end

end
