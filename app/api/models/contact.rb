require 'grape-entity'
require_relative '../../environment_settings'

module IHakula
  module API
    module Models

      class Contact < Grape::Entity
        include IHakula::EnvironmentSettings
        load_config_into_instance 'config.yml'


        expose :id, documentation: {
                      type: String,
                      not_empty: true,
                      desc: 'The contact id'
                  }

        expose :user_id, documentation: {
                      type: String,
                      not_empty: true,
                      desc: 'The user id'
                  }

        expose :name, documentation: {
                        type: String,
                        not_empty: true,
                        desc: 'The contact name'
                    }

        expose :phone, documentation: {
                        type: String,
                        not_empty: true,
                        desc: 'The contact phone'
                    }

        expose :address, documentation: {
                         type: String,
                         not_empty: true,
                         desc: 'The contact address'
                     }

        expose :default, documentation: {
                         type: String,
                         not_empty: false,
                         desc: 'The contact is default or not'
                     }

        expose :date, documentation: {
                         type: String,
                         not_empty: true,
                         desc: 'The contact updated date'
                     }
      end
    end
  end
end