require 'grape-entity'
require_relative '../../environment_settings'

module IHakula
  module API
    module Models

      class Order < Grape::Entity
        include IHakula::EnvironmentSettings
        load_config_into_instance 'config.yml'


        expose :id, documentation: {
                      type: String,
                      not_empty: true,
                      desc: 'The order id'
                  }

        expose :user_id, documentation: {
                           type: String,
                           not_empty: true,
                           desc: 'The user id'
                       }

        expose :cart, documentation: {
                        type: String,
                        not_empty: true,
                        desc: 'Goods in cart'
                    }

        expose :sale_price, documentation: {
                         type: String,
                         not_empty: true,
                         desc: 'The price for sale'
                     }

        expose :real_price, documentation: {
                           type: String,
                           not_empty: true,
                           desc: 'The real price for the order'
                       }

        expose :state, documentation: {
                           type: String,
                           not_empty: false,
                           desc: 'The order state'
                       }

        expose :start_date, documentation: {
                        type: String,
                        not_empty: true,
                        desc: 'The order start date'
                    }

        expose :confirm_date, documentation: {
                              type: String,
                              not_empty: true,
                              desc: 'The order confirmed date'
                          }

        expose :delivery_date, documentation: {
                              type: String,
                              not_empty: true,
                              desc: 'The order start delivery date'
                          }

        expose :pay_date, documentation: {
                              type: String,
                              not_empty: true,
                              desc: 'The order pay date'
                          }

        expose :end_date, documentation: {
                              type: String,
                              not_empty: true,
                              desc: 'The order end date'
                          }

        expose :cancel_date, documentation: {
                              type: String,
                              not_empty: true,
                              desc: 'The order cancelled date'
                          }

        expose :deleted_date, documentation: {
                              type: String,
                              not_empty: true,
                              desc: 'The order deleted date'
                          }
      end
    end
  end
end