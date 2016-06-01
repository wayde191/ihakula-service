require_relative '../order_store'

class OrderStoreFactory
  def self.create(app_settings)
    OrderStore.new(app_settings)
  end
end