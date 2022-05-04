module SettingsReader
  module Resolvers
    # Resolve values in environment variable
    class Env < SettingsReader::Resolvers::Abstract
      IDENTIFIER = 'env://'.freeze

      # Returns true when value starts from `env://`
      def resolvable?(value, _path)
        return unless value.respond_to?(:start_with?)

        value.start_with?(IDENTIFIER)
      end

      # Return value of environment variable by removing `env://` prefix and calling `ENV[env_path]`
      def resolve(value, _path)
        env_path = value.to_s.delete_prefix(IDENTIFIER)
        ENV[env_path]
      end
    end
  end
end
