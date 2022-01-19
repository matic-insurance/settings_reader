module Helpers
  module Backends
    def set_custom_value(path, value)
      MemoryResolver.custom_values ||= {}
      MemoryResolver.custom_values[path] = value
    end

    def clear_custom_values
      return unless MemoryResolver.custom_values

      MemoryResolver.custom_values = {}
    end

    class MemoryResolver < SettingsReader::Providers::Abstract
      class << self
        attr_accessor :custom_values
      end

      def get(path)
        cache[absolute_key_path(path)]
      end

      private

      def cache
        self.class.custom_values || {}
      end
    end
  end
end

RSpec.configure do |config|
  config.include(Helpers::Backends)

  config.after do
    clear_custom_values
  end
end
