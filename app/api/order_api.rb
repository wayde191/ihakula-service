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

      end
    end
  end
end
