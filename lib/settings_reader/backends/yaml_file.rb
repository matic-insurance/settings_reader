require 'yaml'

module SettingsReader
  module Backends
    # Provides access to settings stored as YAML file.
    # File will be read once on init and cached in memory:
    #   When file is missing - no error will be raised
    #   When file is invalid - SettingsReader::Error is raised
    class YamlFile < Abstract
      def initialize(file_path)
        super()
        @data = read_yml(file_path)
      end

      def get(path)
        parts = decompose_path(path)
        get_value_from_hash(@data, parts)
      end

      private

      def read_yml(path)
        return {} unless File.exist?(path)

        data = YAML.safe_load(IO.read(path))
        raise SettingsReader::Error, "YML Settings at #{path} file has incorrect structure" unless data.is_a?(Hash)

        data
      rescue Psych::SyntaxError, Errno::ENOENT => e
        raise SettingsReader::Error, "Cannot read settings file at #{path}: #{e.message}"
      end
    end
  end
end
