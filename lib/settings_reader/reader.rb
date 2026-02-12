module SettingsReader
  # Orchestrates fetching values from backend and resolving them
  class Reader
    include SettingsReader::Mixins::Path

    NO_VALUE = Object.new.freeze

    def initialize(base_path, config)
      @base_path = base_path
      @config = config
      @backends = config.backends
      @resolvers = config.resolvers
    end

    def get(sub_path)
      full_path = generate_path(@base_path, sub_path)
      value = fetch_value(full_path)
      resolve_value(value, full_path)
    end

    # raises error if value is not found in any backend and default is not provided
    def fetch(sub_path, default = NO_VALUE)
      full_path = generate_path(@base_path, sub_path)
      value = fetch_value(full_path)

      return value unless value.nil?
      return default unless default.equal?(NO_VALUE)

      raise SettingsReader::Error, "Value not found in any backend: '#{generate_path(@base_path, sub_path)}'"
    end

    alias [] get

    def load(sub_path)
      new_path = generate_path(@base_path, sub_path)
      SettingsReader::Reader.new(new_path, @config)
    end

    def blank?
      @backends.all? { |backend| backend.get(@base_path).nil? }
    end

    def present?
      !blank?
    end

    protected

    def check_deep_structure(value, path)
      return unless value.is_a?(Hash)

      message = "Getting value of complex object at path: '#{path}'. Use #load method to get new scoped instance"
      raise SettingsReader::Error, message if value.is_a?(Hash)
    end

    def fetch_value(path)
      @backends.each do |backend|
        value = backend.get(path)
        check_deep_structure(value, path)
        return value unless value.nil?
      end
      nil
    end

    def resolve_value(value, path)
      resolver = @resolvers.detect { |r| r.resolvable?(value, path) }
      if resolver
        resolver.resolve(value, path)
      else
        value
      end
    end
  end
end
