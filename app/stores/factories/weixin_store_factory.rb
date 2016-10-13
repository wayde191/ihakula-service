require_relative '../weixin_store'

class WeixinStoreFactory
  def self.create(app_settings)
    WeixinStore.new(app_settings)
  end
end