module SettingsReader
  module Resolvers
    # Run values through ERB
    class Erb < SettingsReader::Resolvers::Abstract
      IDENTIFIER = /(<%=).*(%>)/.freeze

      # Returns true when value contain Erb template <%= code_is_here %>
      def resolvable?(value, _path)
        return unless value.is_a?(String)

        IDENTIFIER.match?(value)
      end

      # Renders value using ERB
      def resolve(value, _path)
        ERB.new(value.to_s).result
      end
    end
  end
end
