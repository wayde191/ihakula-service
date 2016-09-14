require_relative '../../app/database/joke_db'
require_relative '../../app/exceptions/ihakula_service_error'

class JokeStore

  def initialize(app_settings)
    @settings = app_settings
    @logger = LogWrapper.new(app_settings, LogFormatter.new)
  end

  def get_joke(page_num)
    begin
      batch_num = 20
      Joke.limit(batch_num).offset((page_num.to_i - 1) * batch_num).order('id desc')
    rescue StandardError => ex
      raise IhakulaServiceError, ex.message
    end
  end

end
