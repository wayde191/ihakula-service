require_relative '../../app/database/user_db'
require_relative '../../app/exceptions/ihakula_service_error'

class UserStore

  def initialize(app_settings)
    @settings = app_settings
    @logger = LogWrapper.new(app_settings, LogFormatter.new)

  end

  def get_contact(user_id)
    begin
      contact = Ih_contact.where(user_id: user_id)
      contact
    rescue StandardError => ex
      p ex.message
      raise IhakulaServiceError
    end
  end
end
