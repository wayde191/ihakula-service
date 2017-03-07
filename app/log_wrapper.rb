require 'logger'

class LogWrapper
  def initialize(settings, log_formatter, logger = Logger.new(settings.log_path))
    @log_formatter = log_formatter
    @logger = logger
  end

  def error_details(message, request, request_parameters, source)
    message = @log_formatter.format_error_details(message, request, request_parameters, source)
    @logger.error(message)
  end

  def request_details(request)
    message = @log_formatter.format_request_details(request)
    @logger.info(message)
  end

  def response_details(response, status, headers)
    message = @log_formatter.format_response_details(response, status, headers)
    @logger.info(message)
  end

  def log_info(message)
    @logger.info("Debug Logs: #{message}")
  end

end