require 'grape'
require 'ostruct'
require 'grape-swagger'
require_relative 'dirty_grape_method_missing_override'
require_relative 'environment_settings'

require_relative '../app/api/status_codes'
require_relative '../app/api/accounts_api'
require_relative '../app/api/order_api'
require_relative '../app/api/user_api'
require_relative '../app/api/fund_api'
require_relative '../app/api/joke_api'
require_relative '../app/api/wordpress_api'
require_relative '../app/api/tool_api'
require_relative '../app/api/weixin_api'

module IHakula
  class Application < Grape::API
    include StatusCodes

    version 'v1', using: :header, vendor: 'ihakula.com'
    format :json
    default_format :json

    include IHakula::EnvironmentSettings
    config_file './config.yml'

    I18n.enforce_available_locales = false

    mount IHakula::API::AccountsAPI
    mount IHakula::API::OrderAPI
    mount IHakula::API::UserAPI
    mount IHakula::API::FundAPI
    mount IHakula::API::JokeAPI
    mount IHakula::API::WordpressAPI
    mount IHakula::API::ToolAPI
    mount IHakula::API::WeixinAPI

    add_swagger_documentation hide_format: true, hide_documentation_path: true
  end
end
