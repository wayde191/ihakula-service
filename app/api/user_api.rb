require 'grape'
require 'grape-swagger'

require_relative '../../app/api/status_codes'
require_relative '../../app/stores/factories/user_store_factory'
require_relative '../../app/api/validators/not_empty'
require_relative '../../app/exceptions/ihakula_service_error'

require_relative '../../app/api/models/contact'
require_relative '../../app/api/models/wx_user'

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

        def unauthenticated!(message, headers = nil)
          error! message, 401, headers
        end

        def check_token
          token = headers['Authorization']
          unauthenticated! 'Not Authenticated!' if token.nil?
          token = token.sub! 'Bearer ', ''
          @token_record = user_store.get_token_record token
          unauthenticated! 'Not Authenticated!' if @token_record.nil?
        end
      end

      desc 'Operations on iHakula User'
      resource :user do
        params do
        end
        route_param :house_id do
          before do
            check_token
          end

          desc 'rent house'
          params do
            requires :invite_code, type: String, not_empty: true, desc: 'Rent house invite code'
          end
          post '/rent', http_codes: [[OK, OK_MESSAGE], [FAILURE, SERVER_ERROR]] do
            begin
              user_store.rent_house(@token_record['user_id'], params[:invite_code], params[:house_id])
              status OK
            rescue IhakulaServiceError => ex
              status FAILURE
              {error:SERVER_ERROR, message:ex.message}
            end
          end

          desc 'get house detail info'
          get '/detail', http_codes: [[OK, OK_MESSAGE], [FAILURE, SERVER_ERROR]] do
            begin
              user_store.get_house_detail(params[:house_id])
            rescue IhakulaServiceError => ex
              status FAILURE
              {error:SERVER_ERROR, message:ex.message}
            end
          end
        end

        desc 'Get user house asset'
        get '/get-user-asset', http_codes: [[OK, OK_MESSAGE], [FAILURE, SERVER_ERROR]] do
          begin
            check_token
            user_store.get_user_asset @token_record['user_id']
          rescue IhakulaServiceError => ex
            status FAILURE
            {error:SERVER_ERROR, message:ex.message}
          end
        end

        desc 'Fill user info'
        params do
          requires :phone, type: String, not_empty: true, desc: 'User phone'
        end
        put '/fill-user-info', http_codes: [[OK, OK_MESSAGE], [FAILURE, SERVER_ERROR]] do
          begin
            check_token
            user_store.fill_user_info(params[:phone], @token_record['user_id'])
            status UPDATED
          rescue IhakulaServiceError => ex
            status FAILURE
            {error:SERVER_ERROR, message:ex.message}
          end
        end

        desc 'Get token for wechat', is_array: false
        params do
          requires :all, except: [], using: Models::Wx_user.documentation
        end
        post '/get-wx-token', http_codes: [[OK, OK_MESSAGE], [FAILURE, SERVER_ERROR]] do
          begin
            user_store.get_wx_token params
          rescue IhakulaServiceError => ex
            status FAILURE
            {error:SERVER_ERROR, message:ex.message}
          end
        end

        desc 'Get house list ', is_array: true
        params do
        end
        post '/get-house-list', http_codes: [[OK, OK_MESSAGE], [FAILURE, SERVER_ERROR]] do
          begin
            check_token
            user_store.get_wx_house
          rescue IhakulaServiceError => ex
            status FAILURE
            {error:SERVER_ERROR, message:ex.message}
          end
        end

        # ===================================================================

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
            user_store.get_contact(params[:user_id])
          rescue IhakulaServiceError => ex
            status FAILURE
            {error:SERVER_ERROR, message:ex.message}
          end
        end

        desc 'Create user contacts', is_array: false
        params do
          requires :all, except: [:id, :default, :date], using: Models::Contact.documentation
        end
        post '/create-contact', http_codes: [[OK, OK_MESSAGE], [MALFORMED_REQUEST, MALFORMED_REQUEST_DESCRIPTION], [FAILURE, SERVER_ERROR]] do
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
        put '/update-contact', http_codes: [[OK, OK_MESSAGE], [MALFORMED_REQUEST, MALFORMED_REQUEST_DESCRIPTION], [FAILURE, SERVER_ERROR]] do
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
