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
      end

      desc 'Operations on iHakula Joke'
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

    end
  end
end
