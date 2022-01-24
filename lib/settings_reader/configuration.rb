module SettingsReader
  # All gem configuration settings
  class Configuration
    DEFAULT_BASE_FILE_PATH = 'config/app_settings.yml'.freeze
    DEFAULT_LOCAL_FILE_PATH = 'config/app_settings.local.yml'.freeze
    DEFAULT_BACKENDS = [
      SettingsReader::Backends::LocalStorage
    ].freeze
    DEFAULT_RESOLVERS = [
      SettingsReader::Resolvers::Env
    ].freeze
    attr_accessor :base_file_path, :local_file_path,
                  :backends, :resolvers

    def initialize
      @base_file_path = DEFAULT_BASE_FILE_PATH
      @local_file_path = DEFAULT_LOCAL_FILE_PATH
      @backends = DEFAULT_BACKENDS
      @resolvers = DEFAULT_RESOLVERS
    end
  end
end
