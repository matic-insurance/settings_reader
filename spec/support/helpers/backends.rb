module Helpers
  module Backends
    def set_custom_value(path, value)
      MemoryBackend.custom_values ||= {}
      MemoryBackend.custom_values[path] = value
    end

    def clear_custom_values
      return unless MemoryBackend.custom_values

      MemoryBackend.custom_values = {}
    end

    class MemoryBackend
      class << self
        attr_accessor :custom_values
      end

      def get(path)
        cache[path]
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
