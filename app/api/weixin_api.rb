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

      MALFORMED_REQUEST_DESCRIPTION = 'Malformed Request'
      SERVER_ERROR = 'Server Error'
      OK_MESSAGE = 'Ok'

      format :json
      content_type :json, 'application/json; charset=utf-8'

      helpers do
        def weixin_store
          WeixinStoreFactory::create(settings)
        end
      end

      desc 'Operations on iHakula Joke'
      resource :weixin do

        desc 'Get validated neighbours', is_array: true
        params do
        end
        get '/get-validated-neighbours', http_codes: [
                           [OK, OK_MESSAGE],
                           [MALFORMED_REQUEST, MALFORMED_REQUEST_DESCRIPTION],
                           [FAILURE, SERVER_ERROR]
                       ] do
          begin
            weixin_store.get_validated_neighbours()
          rescue IhakulaServiceError => ex
            status FAILURE
            {error:SERVER_ERROR, message:ex.message}
          end
        end

      end

    end
  end
end
