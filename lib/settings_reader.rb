require 'settings_reader/mixins/path'
require 'settings_reader/mixins/values'
require 'settings_reader/backends/abstract'
require 'settings_reader/backends/yaml_file'
require 'settings_reader/resolvers/abstract'
require 'settings_reader/resolvers/env'
require 'settings_reader/resolvers/erb'
require 'settings_reader/configuration'
require 'settings_reader/reader'
require 'settings_reader/version'

# Flexible Settings reader with support of custom backends and value resolutions
module SettingsReader
  class Error < StandardError; end

  def self.load(base_path = '')
    configuration = SettingsReader::Configuration.new
    yield(configuration) if block_given?
    Reader.new(base_path, configuration)
  end
end
