require_relative '../wordpress_store'
require_relative '../../../app/middleware/http_client_factory'

class WordpressStoreFactory
  def self.create(app_settings)
    WordpressStore.new(app_settings, HttpClientFactory::create(app_settings))
  end
end