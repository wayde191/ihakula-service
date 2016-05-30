require 'yaml'

module SettingsLoader
  def self.load_settings(config_file_location, &block)
    @config_file_location = config_file_location
    environment = ENV['RACK_ENV']

    yaml = YAML::load(File.open(@config_file_location)).fetch(environment)
    if block_given?
      yaml.each_pair do |key, value|
        block.call(key, value)
      end
    else
      yaml
    end
  end
end