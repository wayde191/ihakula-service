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
      ACCOUNT_OWNER_NOT_FOUND = 'Account owner not found'
      OK_MESSAGE = 'Ok'

      helpers do
        def order_store
          OrderStoreFactory::create(settings)
        end
      end

      desc 'Operations on Order'
      resource :order do

        desc 'Returns all accounts', is_array: true
        params do
          optional :active_only, type:Boolean, default: false, desc: 'Return only active accounts (default: false)'
        end
        get '/', http_codes: [
                   [OK, OK_MESSAGE],
                   [MALFORMED_REQUEST, MALFORMED_REQUEST_DESCRIPTION],
                   [FAILURE, SERVER_ERROR]
               ] do
          'hello world'
        end
      end
    end
  end
end
