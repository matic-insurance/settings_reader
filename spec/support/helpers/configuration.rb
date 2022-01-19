module Helpers
  module Configuration
    def fixture_path(defaults_fixture)
      File.expand_path("../fixtures/#{defaults_fixture}.yml", __dir__)
    end
  end
end

RSpec.configure do |config|
  config.include(Helpers::Configuration)

  config.before do
    SettingsReader.configure do |settings_config|
      settings_config.base_file_path = fixture_path('base_application_settings')
      settings_config.settings_providers = [
        Helpers::Backends::MemoryResolver,
        SettingsReader::Providers::LocalStorage
      ]
    end
  end

  config.after do
    SettingsReader.config = SettingsReader::Configuration.new
  end
end
