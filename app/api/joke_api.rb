require 'grape'
require 'grape-swagger'

require_relative '../../app/api/status_codes'
require_relative '../../app/stores/factories/joke_store_factory'
require_relative '../../app/api/validators/not_empty'
require_relative '../../app/exceptions/ihakula_service_error'

include StatusCodes

module IHakula
  module API
    class JokeAPI < Grape::API

      MALFORMED_REQUEST_DESCRIPTION = 'Malformed Request'
      SERVER_ERROR = 'Server Error'
      OK_MESSAGE = 'Ok'

      format :json
      content_type :json, 'application/json; charset=utf-8'

      helpers do
        def joke_store
          JokeStoreFactory::create(settings)
        end
      end

      desc 'Operations on iHakula Joke'
      resource :joke do

        desc 'Get pagination jokes', is_array: true
        params do
          requires :page_num, type: String, not_empty: true, desc: 'Page number'
        end
        get '/get-joke', http_codes: [
                              [OK, OK_MESSAGE],
                              [MALFORMED_REQUEST, MALFORMED_REQUEST_DESCRIPTION],
                              [FAILURE, SERVER_ERROR]
                          ] do
          begin
            joke_store.get_joke(params[:page_num])
          rescue IhakulaServiceError => ex
            status FAILURE
            {error:SERVER_ERROR, message:ex.message}
          end
        end


      end
    end
  end
end
