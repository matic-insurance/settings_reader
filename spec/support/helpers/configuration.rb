module Helpers
  module Configuration
    def fixture_path(defaults_fixture)
      File.expand_path("../fixtures/#{defaults_fixture}.yml", __dir__)
    end

    def testing_config
      config = SettingsReader::Configuration.new
      config.backends = [
        Helpers::Backends::MemoryBackend.new,
        SettingsReader::Backends::YamlFile.new(fixture_path('base_application_settings'))
      ]
      config
    end

    def testing_settings
      SettingsReader.load do |config|
        config.backends = [
          Helpers::Backends::MemoryBackend.new,
          SettingsReader::Backends::YamlFile.new(fixture_path('base_application_settings'))
        ]
      end
    end
  end
end

RSpec.configure do |config|
  config.include(Helpers::Configuration)
end
