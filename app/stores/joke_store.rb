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
      jokes = Joke.limit(batch_num).offset((page_num.to_i - 1) * batch_num).order('id desc')
      jokes_detail = []
      jokes.each do |joke|
        detail = JokeContent.where(doc_id: joke[:doc_id])
        jokes_detail << {joke: joke, detail: detail} if detail.size != 0
      end
      jokes_detail
    rescue StandardError => ex
      write_exception_details_to_log(ex, 'get_joke', 'paras')
      raise IhakulaServiceError, ex.message
    end
  end

  private
  def get_joke_doc_id(jokes)

  end

  def write_exception_details_to_log(exception, request, request_parameters)
    puts exception.message
    @logger.error_details(exception.message, request, request_parameters, 'IhakulaStore')
  end

end
