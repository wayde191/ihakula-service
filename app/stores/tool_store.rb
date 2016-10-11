require 'csv'

require_relative '../../app/exceptions/ihakula_service_error'

class ToolStore

  def initialize(app_settings)
    @settings = app_settings
    @logger = LogWrapper.new(app_settings, LogFormatter.new)
  end

  def get_validated_neighbours
    begin
      result = []
      CSV.foreach('uploads/neighbour.csv', 'r:UTF-8') do |user|
        result.push user
      end
      result
    rescue StandardError => ex
      raise IhakulaServiceError, ex.message
    end
  end

end
