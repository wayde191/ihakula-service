require_relative '../user_store'
require_relative '../../../app/middleware/http_client_factory'

class UserStoreFactory
  def self.create(app_settings)
    UserStore.new(app_settings, HttpClientFactory::create(app_settings))
  end
end