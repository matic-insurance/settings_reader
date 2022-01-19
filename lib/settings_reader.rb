require 'settings_reader/version'
require 'settings_reader/providers/abstract'
require 'settings_reader/providers/local_storage'
require 'settings_reader/resolvers/abstract'
require 'settings_reader/resolvers/env'
require 'settings_reader/resolvers/erb'
require 'settings_reader/configuration'
require 'settings_reader/reader'
require 'settings_reader/utils'

# Flexible Settings reader with support of custom backends and value resolutions
module SettingsReader
  class Error < StandardError; end

  class << self
    attr_accessor :config
  end

  self.config ||= SettingsReader::Configuration.new

  def self.configure
    yield(config)
  end

  def self.load(path = '')
    Reader.new(path, config)
  end
end
