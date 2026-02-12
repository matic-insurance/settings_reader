module SettingsReader
  # All gem configuration settings
  class Configuration
    attr_accessor :backends, :resolvers

    def initialize(backends: yaml_backends, resolvers: [SettingsReader::Resolvers::Env.new])
      @backends = backends
      @resolvers = resolvers
    end

    private

    def yaml_backends
      settings_filepaths.map { |filepath| SettingsReader::Backends::YamlFile.new(filepath) }
    end

    def settings_filepaths
      # Order of paths is important - more specific files should be loaded first
      # to override values from more generic ones
      [
        ("config/app_settings.#{rails_env}.local.yml" if rails_env),
        'config/app_settings.local.yml',
        ("config/app_settings.#{rails_env}.yml" if rails_env),
        'config/app_settings.yml'
      ].compact
    end

    def rails_env
      ENV.fetch('RAILS_ENV', nil)
    end
  end
end
