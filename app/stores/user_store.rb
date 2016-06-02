require_relative '../../app/database/user_db'
require_relative '../../app/exceptions/ihakula_service_error'

class UserStore

  def initialize(app_settings)
    @settings = app_settings
    @logger = LogWrapper.new(app_settings, LogFormatter.new)

  end

  def get_contact(user_id)
    begin
      Ih_contact.where(user_id: user_id)
    rescue StandardError => ex
      raise IhakulaServiceError, ex.message
    end
  end

  def create_contact(parameters)
    begin
      Ih_contact.create(
          name: parameters[:name],
          phone: parameters[:phone],
          address: parameters[:address],
          user_id: parameters[:user_id],
          default: 'no',
          date: get_current_time
      )
    rescue StandardError => ex
      raise IhakulaServiceError, ex.message
    end
  end

  private
  def get_current_time
    Time.now.strftime('%Y-%m-%d %H:%M:%S')
  end
end
