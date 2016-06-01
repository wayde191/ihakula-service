require_relative '../database/order_db'

class OrderStore

  def initialize(app_settings)
    @app_settings = app_settings;
  end

  def create
    'hello order'
  end
end
