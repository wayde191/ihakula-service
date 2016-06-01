require_relative '../user_store'

class UserStoreFactory
  def self.create(app_settings)
    UserStore.new(app_settings)
  end
end