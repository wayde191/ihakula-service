require_relative '../joke_store'

class JokeStoreFactory
  def self.create(app_settings)
    JokeStore.new(app_settings)
  end
end