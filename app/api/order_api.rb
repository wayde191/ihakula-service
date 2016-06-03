require 'grape'
require 'grape-swagger'

require_relative '../../app/stores/factories/order_store_factory'
require_relative '../../app/api/status_codes'
require_relative '../../app/api/validators/not_empty'
require_relative '../../app/exceptions/ihakula_service_error'

require_relative '../../app/api/models/order'

include StatusCodes

module IHakula
  module API
    class OrderAPI < Grape::API

      MALFORMED_REQUEST_DESCRIPTION = 'Malformed Request'
      SERVER_ERROR = 'Server Error'
      OK_MESSAGE = 'Ok'

      helpers do
        def order_store
          OrderStoreFactory::create(settings)
        end
      end

      desc 'Operations on Order'
      resource :order do

        desc 'Create order', is_array: false
        params do
          requires :all, except: [:id, :order_number, :state,
                                  :start_date, :confirm_date,
                                  :delivery_date, :pay_date,
                                  :end_date, :cancel_date,
                                  :deleted_date], using: Models::Order.documentation
        end
        post '/create-contact', http_codes: [
                                  [OK, OK_MESSAGE],
                                  [MALFORMED_REQUEST, MALFORMED_REQUEST_DESCRIPTION],
                                  [FAILURE, SERVER_ERROR]
                              ] do
          begin
            order_store.create_order(params)
          rescue IhakulaServiceError => ex
            status FAILURE
            {error:SERVER_ERROR, message:ex.message}
          end
        end

        desc 'Get orders owned by user', is_array: true
        params do
          requires :user_id, type: String, not_empty: true, desc: 'User Id'
        end
        get '/get-user-orders', http_codes: [
                              [OK, OK_MESSAGE],
                              [MALFORMED_REQUEST, MALFORMED_REQUEST_DESCRIPTION],
                              [FAILURE, SERVER_ERROR]
                          ] do
          begin
            order_store.get_user_orders(params[:user_id])
          rescue IhakulaServiceError => ex
            status FAILURE
            {error:SERVER_ERROR, message:ex.message}
          end
        end

        desc 'Accept order', is_array: false
        params do
          requires :all, except: [:user_id, :cart, :sale_price, :real_price, :state,
                                  :start_date, :confirm_date,
                                  :delivery_date, :pay_date,
                                  :end_date, :cancel_date,
                                  :deleted_date], using: Models::Order.documentation
        end
        put '/accept-order', http_codes: [
                                 [OK, OK_MESSAGE],
                                 [MALFORMED_REQUEST, MALFORMED_REQUEST_DESCRIPTION],
                                 [FAILURE, SERVER_ERROR]
                             ] do
          begin
            order_store.accept_order(params)
            status UPDATED
          rescue IhakulaServiceError => ex
            status FAILURE
            {error:SERVER_ERROR, message:ex.message}
          end
        end

        desc 'Delivery order', is_array: false
        params do
          requires :all, except: [:user_id, :cart, :sale_price, :real_price, :state,
                                  :start_date, :confirm_date,
                                  :delivery_date, :pay_date,
                                  :end_date, :cancel_date,
                                  :deleted_date], using: Models::Order.documentation
        end
        put '/delivery-order', http_codes: [
                               [OK, OK_MESSAGE],
                               [MALFORMED_REQUEST, MALFORMED_REQUEST_DESCRIPTION],
                               [FAILURE, SERVER_ERROR]
                           ] do
          begin
            order_store.delivery_order(params)
            status UPDATED
          rescue IhakulaServiceError => ex
            status FAILURE
            {error:SERVER_ERROR, message:ex.message}
          end
        end


        desc 'Pay for order', is_array: false
        params do
          requires :all, except: [:user_id, :cart, :sale_price, :real_price, :state,
                                  :start_date, :confirm_date,
                                  :delivery_date, :pay_date,
                                  :end_date, :cancel_date,
                                  :deleted_date], using: Models::Order.documentation
        end
        put '/pay-for-order', http_codes: [
                                 [OK, OK_MESSAGE],
                                 [MALFORMED_REQUEST, MALFORMED_REQUEST_DESCRIPTION],
                                 [FAILURE, SERVER_ERROR]
                             ] do
          begin
            order_store.pay_for_order(params)
            status UPDATED
          rescue IhakulaServiceError => ex
            status FAILURE
            {error:SERVER_ERROR, message:ex.message}
          end
        end

        desc 'Done order', is_array: false
        params do
          requires :all, except: [:user_id, :cart, :sale_price, :real_price, :state,
                                  :start_date, :confirm_date,
                                  :delivery_date, :pay_date,
                                  :end_date, :cancel_date,
                                  :deleted_date], using: Models::Order.documentation
        end
        put '/done-order', http_codes: [
                                [OK, OK_MESSAGE],
                                [MALFORMED_REQUEST, MALFORMED_REQUEST_DESCRIPTION],
                                [FAILURE, SERVER_ERROR]
                            ] do
          begin
            order_store.done_order(params)
            status UPDATED
          rescue IhakulaServiceError => ex
            status FAILURE
            {error:SERVER_ERROR, message:ex.message}
          end
        end

        desc 'Cancel order', is_array: false
        params do
          requires :all, except: [:user_id, :cart, :sale_price, :real_price, :state,
                                  :start_date, :confirm_date,
                                  :delivery_date, :pay_date,
                                  :end_date, :cancel_date,
                                  :deleted_date], using: Models::Order.documentation
        end
        put '/cancel-order', http_codes: [
                             [OK, OK_MESSAGE],
                             [MALFORMED_REQUEST, MALFORMED_REQUEST_DESCRIPTION],
                             [FAILURE, SERVER_ERROR]
                         ] do
          begin
            order_store.cancel_order(params)
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
