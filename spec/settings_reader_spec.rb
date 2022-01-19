RSpec.describe SettingsReader do
  it 'has a version number' do
    expect(SettingsReader::VERSION).not_to be nil
  end

  it 'has load method' do
    expect(SettingsReader).to respond_to(:load)
  end

  describe 'integration flows', :default_settings_file do
    describe 'providers priority' do
      it 'reads value from consul' do
        set_custom_value('application/name', 'bar')
        settings = described_class.load
        expect(settings.get('application/name')).to eq('bar')
      end

      it 'reads value from disk when consul missing' do
        settings = described_class.load
        expect(settings.get('application/name')).to eq('NestedStructure')
      end
    end

    describe 'resolvers' do
      it 'resolves value using Env by default' do
        allow(ENV).to receive(:[]).and_call_original
        allow(ENV).to receive(:[]).with('TEST_DOMAIN').and_return('my.host')
        set_custom_value('application/domain', 'env://TEST_DOMAIN')
        settings = described_class.load
        expect(settings.get('application/domain')).to eq('my.host')
      end

      it 'ignores Erb by default' do
        set_custom_value('application/domain', '<%= 2 + 2 %>')
        settings = described_class.load
        expect(settings.get('application/domain')).to eq('<%= 2 + 2 %>')
      end
    end

    describe 'path operations' do
      it 'supports path in load' do
        settings = described_class.load('application/services')
        expect(settings.get('consul/domain')).to eq('localhost')
      end

      it 'supports additional path in next load' do
        root_settings = described_class.load
        child_settings = root_settings.load('application/services')
        expect(child_settings.get('consul/domain')).to eq('localhost')
      end
    end
  end

  describe '.configure' do
    let(:local_file_path) { 'path2' }

    before { described_class.configure { |config| config.local_file_path = local_file_path } }

    it 'applies values to configuration' do
      expect(described_class.config.local_file_path).to eq(local_file_path)
    end

    it 'preserves default values' do
      expected = fixture_path('base_application_settings')
      expect(described_class.config.base_file_path).to eq(expected)
    end
  end
end
