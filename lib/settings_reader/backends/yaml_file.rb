require 'yaml'
require 'deep_merge'

module SettingsReader
  module Backends
    # Provides access to settings stored in file system with support of base and local files
    class YamlFile < Abstract
      def initialize(file_path)
        super(nil, nil)
        @data = read_yml(file_path)
      end

      def get(path)
        get_value_from_hash(absolute_key_path(path), @data)
      end

      private

      def read_yml(path)
        return {} unless File.exist?(path)

        YAML.safe_load(IO.read(path))
      rescue Psych::SyntaxError, Errno::ENOENT => e
        raise SettingsReader::Error, "Cannot read settings file at #{path}: #{e.message}"
      end
    end
  end
end
