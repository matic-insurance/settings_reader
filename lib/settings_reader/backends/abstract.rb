module SettingsReader
  module Backends
    # Abstract class with basic functionality
    class Abstract
      include SettingsReader::Mixins::Path
      include SettingsReader::Mixins::Values

      def get(_path)
        raise NotImplementedError
      end
    end
  end
end
