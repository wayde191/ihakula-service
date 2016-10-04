require 'uri'
require 'rest_client'
require 'ostruct'
require_relative '../../app/exceptions/external_error'
require_relative '../../app/exceptions/duplicate_error'
require_relative '../../app/log_wrapper'

class HTTPClient

  def initialize(log_wrapper)
    @logger = log_wrapper
  end

  def get(path, headers = {})
    uri = URI.escape(path)
    begin
      response = RestClient.get uri, headers
    rescue => ex
      @logger.error_details(ex.inspect, path, {}, headers)
      raise ExternalError
    end

    if response.code.to_i >= 500
      @logger.error_details(response.inspect, path, {}, headers)
      raise ExternalError
    end

    create_parsed_response response
  end

  def post(path, data, headers = {})
    uri = URI.escape(path)
    begin
      response = RestClient.post uri, data, {:content_type => :json, :accept => :json}.merge(headers)
    rescue => ex
      @logger.error_details(ex.inspect, path, data, headers)
      if(ex.http_code == 409)
        raise DuplicateError
      end
      raise ExternalError
    end

    if response.code.to_i >= 400
      @logger.error_details(response.inspect, path, data, headers)
      raise ExternalError
    end

    response
  end

  def put(path, data, headers = {})
    uri = URI.escape(path)
    begin
      response = RestClient.put uri, data, {:content_type => :json, :accept => :json}.merge(headers)
    rescue => ex
      @logger.error_details(ex.inspect, path, data, headers)
      raise ExternalError
    end

    if response.code.to_i >= 400
      @logger.error_details(response.inspect, path, data, headers)
      raise ExternalError
    end

    response
  end

  def delete(path, headers = {})
    uri = URI.escape(path)
    begin
      response = RestClient.delete uri, {:content_type => :json, :accept => :json}.merge(headers)
    rescue => ex
      @logger.error_details(ex.inspect, path, {}, headers)
      raise ExternalError
    end

    if response.code.to_i >= 400
      @logger.error_details(response.inspect, path, {}, headers)
      raise ExternalError
    end

    response
  end

  private

  def create_parsed_response(response)
    parsed_response = OpenStruct.new
    parsed_response.code = response.code

    begin
      parsed_response.body = JSON.parse(response.body, symbolize_names: true)
      parsed_response.headers = response.headers
    rescue => ex
      parsed_response.body = response.body
    end

    parsed_response
  end
end
