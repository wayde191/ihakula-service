require_relative '../tool_store'

class ToolStoreFactory
  def self.create(app_settings)
    ToolStore.new(app_settings)
  end
end