require 'ostruct'
require_relative '../app/settings_loader'

module IHakula

  module EnvironmentSettings

    def self.included(base)
      base.send :extend, ClassMethods
    end

    module ClassMethods
      def load_config_into_instance(config_file_name)
        settings_hash = Hash.new
        SettingsLoader::load_settings(config_file_name) do |key, value|
          settings_hash[key] = value
        end

        @settings = OpenStruct.new(settings_hash)
      end

      def config_file(config_file_name)
        SettingsLoader::load_settings(config_file_name) do |key, value|
          set key, value
        end
      end

    end
  end
end

