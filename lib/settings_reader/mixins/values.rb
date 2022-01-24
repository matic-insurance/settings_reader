module SettingsReader
  module Mixins
    # Value casting utility methods
    module Values
      PARSING_CLASSES = [Integer, Float, ->(value) { JSON.parse(value) }].freeze

      def cast_value_from_string(value)
        return nil if value.nil?
        return false if value == 'false'
        return true if value == 'true'
        return value if value.is_a?(Hash)
        return convert_to_hash(value) if value.is_a?(Array)

        cast_complex_value(value)
      end

      def get_value_from_hash(data, path_parts)
        data.dig(*path_parts).clone
      end

      protected

      def cast_complex_value(value)
        PARSING_CLASSES.each do |parser|
          return parser.call(value)
        rescue StandardError => _e
          nil
        end
        value.to_s
      end

      def convert_to_hash(data)
        data_h = data.map do |item|
          value = cast_value_from_string(item[:value])
          item[:key].split('/').reverse.reduce(value) { |h, v| { v => h } }
        end
        data_h.reduce({}) do |dest, source|
          DeepMerge.deep_merge!(source, dest, preserve_unmergeables: true)
        end
      end
    end
  end
end
