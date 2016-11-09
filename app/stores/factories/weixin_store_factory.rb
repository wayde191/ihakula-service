require_relative '../weixin_store'
require_relative '../weixin_zy_store'
require_relative '../../../app/middleware/http_client_factory'

class WeixinStoreFactory
  def self.create(session, app_settings)
    WeixinStore.new(session, app_settings, HttpClientFactory::create(app_settings))
  end

  def self.create_zy(session, app_settings)
    WeixinZyStore.new(session, app_settings, HttpClientFactory::create(app_settings))
  end
end