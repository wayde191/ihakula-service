require_relative '../../app/database/user_db'
require_relative '../../app/exceptions/ihakula_service_error'

class FundStore

  def initialize(app_settings)
    @settings = app_settings
    @logger = LogWrapper.new(app_settings, LogFormatter.new)

  end

end
