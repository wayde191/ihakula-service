class UserStore

  def initialize(app_settings)
    @settings = app_settings
    @logger = LogWrapper.new(LogFormatter.new, settings)

  end

  def create
    'hello order'
  end
end
