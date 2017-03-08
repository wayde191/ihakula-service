require 'grape-entity'
require_relative '../../environment_settings'

module IHakula
  module API
    module Models

      class Wx_user < Grape::Entity
        include IHakula::EnvironmentSettings
        load_config_into_instance 'config.yml'

        expose :app_id, documentation: {
            type: String,
            not_empty: true,
            desc: 'The Wechat little program app id'
        }

        expose :code, documentation: {
                      type: String,
                      not_empty: true,
                      desc: 'The Wechat login code'
                  }

        expose :encrypted_data, documentation: {
                        type: String,
                        not_empty: true,
                        desc: 'Wechat userinfo encryptedData'
                    }

        expose :iv, documentation: {
                         type: String,
                         not_empty: true,
                         desc: 'Wechat userinfo iv'
                     }
      end
    end
  end
end