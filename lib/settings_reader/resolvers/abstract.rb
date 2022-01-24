module SettingsReader
  module Resolvers
    # Abstract resolver interface
    class Abstract
      include SettingsReader::Mixins::Values

      # Should return true if value is resolvable
      def resolvable?(_value, _path)
        false
      end

      # Should resolve value
      def resolve(value, _path)
        value
      end
    end
  end
end
