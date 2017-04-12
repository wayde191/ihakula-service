require 'grape'
require 'grape-swagger'

require_relative '../../app/api/status_codes'
require_relative '../../app/stores/factories/weixin_store_factory'
require_relative '../../app/api/validators/not_empty'
require_relative '../../app/exceptions/ihakula_service_error'

include StatusCodes

module IHakula
  module API
    class WeixinAPI < Grape::API
      use Rack::Session::Cookie, :secret => 'ihakula_nh_secret'

      MALFORMED_REQUEST_DESCRIPTION = 'Malformed Request'
      SERVER_ERROR = 'Server Error'
      OK_MESSAGE = 'Ok'

      format :json
      content_type :json, 'application/json; charset=utf-8'

      helpers do
        def session
          env[Rack::Session::Abstract::ENV_SESSION_KEY]
        end

        def weixin_store
          WeixinStoreFactory::create(session, settings)
        end

        def weixin_zy_store
          WeixinStoreFactory::create_zy(session, settings)
        end
      end

      desc 'Operations on iHakula Joke'
      resource :bbs do

        desc 'Get bbs request', is_array: true
        params do
          requires :ihakula_request, type: String, not_empty: true, desc: 'iHakula key'
          requires :params_string, type: String, not_empty: true, desc: 'request params'
          requires :url, type: String, not_empty: true, desc: 'request url'
        end
        get '/event/get', http_codes: [
            [OK, OK_MESSAGE],
            [MALFORMED_REQUEST, MALFORMED_REQUEST_DESCRIPTION],
            [FAILURE, SERVER_ERROR]
        ] do
          begin
            weixin_store.get_bbs(params)
          rescue IhakulaServiceError => ex
            status FAILURE
            {error:SERVER_ERROR, message:ex.message}
          end
        end


      end

      resource :weixin do

        desc 'Get validated neighbours', is_array: true
        params do
          requires :ihakula_request, type: String, not_empty: true, desc: 'iHakula key'
          requires :request_xml, type: String, not_empty: true, desc: 'request data'
        end
        post '/event/center', http_codes: [
                           [OK, OK_MESSAGE],
                           [MALFORMED_REQUEST, MALFORMED_REQUEST_DESCRIPTION],
                           [FAILURE, SERVER_ERROR]
                       ] do
          begin
            weixin_store.event_handler(params)
          rescue IhakulaServiceError => ex
            status FAILURE
            {error:SERVER_ERROR, message:ex.message}
          end
        end

      end

      desc 'Operations on ZY'
      resource :weixin_zy do

        desc 'Response to zycyy weixin request', is_array: true
        params do
          requires :ihakula_request, type: String, not_empty: true, desc: 'iHakula key'
          requires :request_xml, type: String, not_empty: true, desc: 'request data'
        end
        post '/event/center', http_codes: [
                                [OK, OK_MESSAGE],
                                [MALFORMED_REQUEST, MALFORMED_REQUEST_DESCRIPTION],
                                [FAILURE, SERVER_ERROR]
                            ] do
          begin
            weixin_zy_store.event_handler(params)
          rescue IhakulaServiceError => ex
            status FAILURE
            {error:SERVER_ERROR, message:ex.message}
          end
        end

      end

    end
  end
end
