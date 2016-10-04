require_relative '../../app/exceptions/ihakula_service_error'

class WordpressStore

  def initialize(app_settings, http_client)
    @http_client = http_client
    @settings = app_settings
    @logger = LogWrapper.new(app_settings, LogFormatter.new)
  end

  def get_users
    begin
      @http_client.get("#{@settings.no1_service}/users").body
    rescue StandardError => ex
      write_exception_details_to_log(ex, 'get_users', 'paras')
      raise IhakulaServiceError, ex.message
    end
  end

  def get_user(id)
    begin
      @http_client.get("#{@settings.no1_service}/users/#{id}").body
    rescue StandardError => ex
      write_exception_details_to_log(ex, 'get_user', 'paras')
      raise IhakulaServiceError, ex.message
    end
  end

  def get_posts(category, filter)
    begin
      @http_client.get("#{@settings.no1_service}/posts?filter[#{category}]=#{filter}").body
    end
  rescue StandardError => ex
    write_exception_details_to_log(ex, 'get_posts', 'paras')
    raise IhakulaServiceError, ex.message
  end

  def get_post_count
    begin
      response = @http_client.get("#{@settings.no1_service}/posts?page=1&per_page=1")
      {
          total: response.headers[:x_wp_total],
          page: 10
      }
    end
  rescue StandardError => ex
    write_exception_details_to_log(ex, 'get_post_count', 'paras')
    raise IhakulaServiceError, ex.message
  end

  def get_posts_by_page(page)
    begin
      @http_client.get("#{@settings.no1_service}/posts?page=#{page}").body
    end
  rescue StandardError => ex
    write_exception_details_to_log(ex, 'get_posts_by_page', 'paras')
    raise IhakulaServiceError, ex.message
  end

  def get_comments(id)
    begin
      @http_client.get("#{@settings.no1_service}/comments?post=#{id}").body
    end
  rescue StandardError => ex
    write_exception_details_to_log(ex, 'get_comments', 'paras')
    raise IhakulaServiceError, ex.message
  end

  def get_comment_count(post_id)
    begin
      response = @http_client.get("#{@settings.no1_service}/comments?page=1&per_page=1&post=#{post_id}")
      {
          total: response.headers[:x_wp_total],
          page: 10
      }
    end
  rescue StandardError => ex
    write_exception_details_to_log(ex, 'get_post_count', 'paras')
    raise IhakulaServiceError, ex.message
  end

  private

  def write_exception_details_to_log(exception, request, request_parameters)
    puts exception.message
    @logger.error_details(exception.message, request, request_parameters, 'IhakulaStore')
  end

end
