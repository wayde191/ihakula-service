require 'grape'
require 'grape-swagger'

require_relative '../../app/api/status_codes'
require_relative '../../app/stores/factories/user_store_factory'
require_relative '../../app/api/validators/not_empty'
require_relative '../../app/exceptions/ihakula_service_error'

require_relative '../../app/api/models/contact'

include StatusCodes

module IHakula
  module API
    class UserAPI < Grape::API

      MALFORMED_REQUEST_DESCRIPTION = 'Malformed Request'
      SERVER_ERROR = 'Server Error'
      OK_MESSAGE = 'Ok'

      helpers do
        def user_store
          UserStoreFactory::create(settings)
        end
      end

      desc 'Operations on iHakula User'
      resource :user do

        desc 'Get all user contacts', is_array: true
        params do
          requires :user_id, type: String, not_empty: true, desc: 'User Id'
        end
        get '/get-contact', http_codes: [
                   [OK, OK_MESSAGE],
                   [MALFORMED_REQUEST, MALFORMED_REQUEST_DESCRIPTION],
                   [FAILURE, SERVER_ERROR]
               ] do
          begin
            user_store.get_contact(:user_id)
          rescue IhakulaServiceError => ex
            status FAILURE
            {error:SERVER_ERROR, message:ex.message}
          end
        end

        desc 'Create user contacts', is_array: false
        params do
          requires :all, except: [:id, :default, :date], using: Models::Contact.documentation
        end
        post '/create-contact', http_codes: [
                              [OK, OK_MESSAGE],
                              [MALFORMED_REQUEST, MALFORMED_REQUEST_DESCRIPTION],
                              [FAILURE, SERVER_ERROR]
                          ] do
          begin
            user_store.create_contact(params)
          rescue IhakulaServiceError => ex
            status FAILURE
            {error:SERVER_ERROR, message:ex.message}
          end
        end

        desc 'Update user contacts', is_array: false
        params do
          requires :all, except: [:date], using: Models::Contact.documentation
        end
        put '/update-contact', http_codes: [
                                  [OK, OK_MESSAGE],
                                  [MALFORMED_REQUEST, MALFORMED_REQUEST_DESCRIPTION],
                                  [FAILURE, SERVER_ERROR]
                              ] do
          begin
            user_store.update_contact(params)
            status UPDATED
          rescue IhakulaServiceError => ex
            status FAILURE
            {error:SERVER_ERROR, message:ex.message}
          end
        end


      end
    end
  end
end
