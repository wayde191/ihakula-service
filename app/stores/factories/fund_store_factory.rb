require_relative '../fund_store'

class FundStoreFactory
  def self.create(app_settings)
    FundStore.new(app_settings)
  end
end