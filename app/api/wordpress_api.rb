require 'grape'
require 'grape-swagger'

require_relative '../../app/api/status_codes'
require_relative '../../app/stores/factories/wordpress_store_factory'
require_relative '../../app/api/validators/not_empty'
require_relative '../../app/exceptions/ihakula_service_error'

include StatusCodes

module IHakula
  module API
    class WordpressAPI < Grape::API

      MALFORMED_REQUEST_DESCRIPTION = 'Malformed Request'
      SERVER_ERROR = 'Server Error'
      OK_MESSAGE = 'Ok'

      format :json
      content_type :json, 'application/json; charset=utf-8'

      helpers do
        def wordpress_store
          WordpressStoreFactory::create(settings)
        end
      end

      desc 'Operations on iHakula wordpress'
      resource :wordpress do

        desc 'Get post count', is_array: true
        params do
        end
        get '/get-post-count', http_codes: [
                           [OK, OK_MESSAGE],
                           [MALFORMED_REQUEST, MALFORMED_REQUEST_DESCRIPTION],
                           [FAILURE, SERVER_ERROR]
                       ] do
          begin
            wordpress_store.get_post_count()
          rescue IhakulaServiceError => ex
            status FAILURE
            {error:SERVER_ERROR, message:ex.message}
          end
        end

        desc 'Get post by category filter', is_array: true
        params do
          requires :category, type: String, not_empty: true, desc: 'Post filter category'
          requires :filter, type: String, not_empty: true, desc: 'Post filter'
        end
        get '/get-post', http_codes: [
                              [OK, OK_MESSAGE],
                              [MALFORMED_REQUEST, MALFORMED_REQUEST_DESCRIPTION],
                              [FAILURE, SERVER_ERROR]
                          ] do
          begin
            wordpress_store.get_posts(params[:category], params[:filter])
          rescue IhakulaServiceError => ex
            status FAILURE
            {error:SERVER_ERROR, message:ex.message}
          end
        end

        desc 'Get post by page', is_array: true
        params do
          requires :page, type: String, not_empty: true, desc: 'Post page number'
        end
        get '/get-post-by-page', http_codes: [
                           [OK, OK_MESSAGE],
                           [MALFORMED_REQUEST, MALFORMED_REQUEST_DESCRIPTION],
                           [FAILURE, SERVER_ERROR]
                       ] do
          begin
            wordpress_store.get_posts_by_page(params[:page])
          rescue IhakulaServiceError => ex
            status FAILURE
            {error:SERVER_ERROR, message:ex.message}
          end
        end

        desc 'Get post by id', is_array: true
        params do
          requires :id, type: String, not_empty: true, desc: 'Post id'
        end
        get '/get-post-by-id', http_codes: [
                                   [OK, OK_MESSAGE],
                                   [MALFORMED_REQUEST, MALFORMED_REQUEST_DESCRIPTION],
                                   [FAILURE, SERVER_ERROR]
                               ] do
          begin
            wordpress_store.get_posts_by_id(params[:id])
          rescue IhakulaServiceError => ex
            status FAILURE
            {error:SERVER_ERROR, message:ex.message}
          end
        end

        desc 'Get post comment by post id', is_array: true
        params do
          requires :post_id, type: String, not_empty: true, desc: 'Post id'
        end
        get '/get-comment', http_codes: [
                           [OK, OK_MESSAGE],
                           [MALFORMED_REQUEST, MALFORMED_REQUEST_DESCRIPTION],
                           [FAILURE, SERVER_ERROR]
                       ] do
          begin
            wordpress_store.get_comments(params[:post_id])
          rescue IhakulaServiceError => ex
            status FAILURE
            {error:SERVER_ERROR, message:ex.message}
          end
        end

        desc 'Get comment count', is_array: true
        params do
          requires :post_id, type: String, not_empty: true, desc: 'Post id'
        end
        get '/get-comment-count', http_codes: [
                                 [OK, OK_MESSAGE],
                                 [MALFORMED_REQUEST, MALFORMED_REQUEST_DESCRIPTION],
                                 [FAILURE, SERVER_ERROR]
                             ] do
          begin
            wordpress_store.get_comment_count(params[:post_id])
          rescue IhakulaServiceError => ex
            status FAILURE
            {error:SERVER_ERROR, message:ex.message}
          end
        end

        desc 'Get users', is_array: true
        params do
        end
        get '/get-users', http_codes: [
                           [OK, OK_MESSAGE],
                           [MALFORMED_REQUEST, MALFORMED_REQUEST_DESCRIPTION],
                           [FAILURE, SERVER_ERROR]
                       ] do
          begin
            wordpress_store.get_users()
          rescue IhakulaServiceError => ex
            status FAILURE
            {error:SERVER_ERROR, message:ex.message}
          end
        end

        desc 'Get user', is_array: false
        params do
          requires :id, type: String, not_empty: true, desc: 'Post user id'
        end
        get '/get-user', http_codes: [
                           [OK, OK_MESSAGE],
                           [MALFORMED_REQUEST, MALFORMED_REQUEST_DESCRIPTION],
                           [FAILURE, SERVER_ERROR]
                       ] do
          begin
            wordpress_store.get_user(params[:id])
          rescue IhakulaServiceError => ex
            status FAILURE
            {error:SERVER_ERROR, message:ex.message}
          end
        end

      end

    end
  end
end
