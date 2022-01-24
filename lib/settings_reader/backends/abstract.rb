module SettingsReader
  module Backends
    # Abstract class with basic functionality
    class Abstract
      include SettingsReader::Mixins::Path
      include SettingsReader::Mixins::Values

      # get value from backend by full_path or return nil if missing
      def get(_full_path)
        raise NotImplementedError
      end
    end
  end
end
