module SettingsReader
  # All gem configuration settings
  class Configuration
    DEFAULT_BASE_FILE_PATH = 'config/app_settings.yml'.freeze
    DEFAULT_LOCAL_FILE_PATH = 'config/app_settings.local.yml'.freeze
    attr_accessor :backends, :resolvers

    def initialize
      @base_file_path = DEFAULT_BASE_FILE_PATH
      @local_file_path = DEFAULT_LOCAL_FILE_PATH
      @backends = [
        SettingsReader::Backends::YamlFile.new(DEFAULT_LOCAL_FILE_PATH),
        SettingsReader::Backends::YamlFile.new(DEFAULT_BASE_FILE_PATH)
      ]
      @resolvers = [
        SettingsReader::Resolvers::Env.new
      ]
    end
  end
end
