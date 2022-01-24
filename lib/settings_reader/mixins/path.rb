module SettingsReader
  module Mixins
    # Path related utility methods
    module Path
      PATH_SEPARATOR = '/'.freeze

      # Create path from parts using '/' as a separator
      def generate_path(*parts)
        strings = parts.map(&:to_s)
        all_parts = strings.map { |s| s.split(PATH_SEPARATOR) }.flatten
        all_parts.reject(&:empty?).join('/')
      end

      # Create list of parts from path using '/' as separator. Remove empty/nil parts
      def decompose_path(path)
        parts = path.to_s.split(PATH_SEPARATOR).compact
        parts.reject(&:empty?)
      end
    end
  end
end
