class LogFormatter

  def format_error_details(message, request, request_parameters, source)
    "[#{Thread.current[:transaction_id]}] source: [#{source}] request: [#{request}] #{format_request_parameters(request_parameters)} error message: [#{message}]"
  end

  def format_request_details(request)
    body = request.body.read
    request.body.rewind
    "[#{Thread.current[:transaction_id]}] [#{request.request_method}] [#{request.path_info}] params: [#{request.params.to_s}] body: [#{body}]"
  end

  def format_response_details(response, status, headers)
    full_body = response != [] && !response.instance_of?(File) ? response.body.join(', ') : '[]'
    body = full_body.truncate 500
    "[#{Thread.current[:transaction_id]}] [#{status.to_s}] body: #{body} headers: [#{headers.to_s}]"
  end

  private

  def format_request_parameters(request_parameters)
    request_parameters ? "request parameters: [#{request_parameters}]" : ''
  end
end