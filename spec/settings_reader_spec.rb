RSpec.describe SettingsReader do
  it 'has a version number' do
    expect(SettingsReader::VERSION).not_to be nil
  end

  it 'has load method' do
    expect(described_class).to respond_to(:load)
  end

  describe 'integration flows', :default_settings_file do
    describe 'backends priority' do
      it 'reads value from first backend' do
        set_custom_value('application/name', 'bar')
        expect(testing_settings.get('application/name')).to eq('bar')
      end

      it 'reads value from second backend when first missing' do
        expect(testing_settings.get('application/name')).to eq('NestedStructure')
      end
    end

    describe 'resolvers' do
      it 'resolves value using Env by default' do
        allow(ENV).to receive(:[]).and_call_original
        allow(ENV).to receive(:[]).with('TEST_DOMAIN').and_return('my.host')
        set_custom_value('application/domain', 'env://TEST_DOMAIN')
        expect(testing_settings.get('application/domain')).to eq('my.host')
      end

      it 'ignores Erb by default' do
        set_custom_value('application/domain', '<%= 2 + 2 %>')
        expect(testing_settings.get('application/domain')).to eq('<%= 2 + 2 %>')
      end
    end

    describe 'path operations' do
      it 'supports path in load' do
        settings = testing_settings.load('application/services')
        expect(settings.get('consul/domain')).to eq('localhost')
      end

      it 'supports additional path in next load' do
        root_settings = testing_settings
        child_settings = root_settings.load('application/services')
        expect(child_settings.get('consul/domain')).to eq('localhost')
      end
    end
  end
end
