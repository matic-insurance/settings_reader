RSpec.describe SettingsReader::Providers::LocalStorage do
  let(:provider) { described_class.new(base_path, config) }
  let(:base_path) { '' }
  let(:config) do
    SettingsReader::Configuration.new.tap do |config|
      config.base_file_path = base_file_path
      config.local_file_path = local_file_path
    end
  end
  let(:base_file_path) { fixture_path('base_application_settings') }
  let(:local_file_path) { fixture_path('local_application_settings') }

  describe '#get' do
    let(:config) do
      SettingsReader::Configuration.new.tap do |config|
        config.base_file_path = fixture_path('provider_tests')
      end
    end

    context 'when base path is empty' do
      it 'correctly retrieves complex paths' do
        expect(provider.get('root/level_2/level_3/level_4')).to eq('descendant_value')
      end

      it 'correctly retrieves simple paths' do
        expect(provider.get('foo')).to eq('bar')
      end
    end

    context 'when base path is present' do
      let(:provider) { described_class.new('root/level_2', config) }

      it 'correctly retrieves complex paths' do
        expect(provider.get('level_3/level_4')).to eq('descendant_value')
      end

      it 'correctly retrieves simple paths' do
        expect(provider.get('level_2_child')).to eq('child_value')
      end
    end

    context 'when base path is incorrect' do
      let(:provider) { described_class.new('missing_value', config) }

      it 'return nils on complex paths' do
        expect(provider.get('level_3/level_4')).to eq(nil)
      end

      it 'return nils on simple paths' do
        expect(provider.get('children')).to eq(nil)
      end
    end

    context 'when the key is a symbol' do
      it 'correctly retrieves data' do
        expect(provider.get(:foo)).to eq('bar')
      end
    end

    it 'returns string values' do
      expect(provider.get('values/string')).to eq('a string')
    end

    it 'returns boolean values for true' do
      expect(provider.get('values/boolean_true')).to eq(true)
    end

    it 'returns boolean values for false' do
      expect(provider.get('values/boolean_false')).to eq(false)
    end

    it 'returns integer values' do
      expect(provider.get('values/integer')).to eq(123)
    end

    it 'returns float values' do
      expect(provider.get('values/float')).to eq(5.0)
    end

    it 'returns empty values' do
      expect(provider.get('values/empty')).to eq(nil)
    end

    it 'returns nil when missing' do
      expect(provider.get('missing')).to eq(nil)
    end

    it 'returns object values' do
      object = { 'level_2_child' => 'child_value', 'level_3' => { 'level_4' => 'descendant_value' } }
      expect(provider.get('root/level_2')).to eq(object)
    end

    it 'parsing object values' do
      object = { 'boolean_true' => true, 'float' => 5.0, 'integer' => 123, 'string' => 'a string' }
      expect(provider.get('values')).to include(object)
    end
  end

  describe 'base and local files' do
    context 'when base path is empty' do
      it 'correctly retrieves complex paths' do
        expect(provider.get('application/services/consul/domain')).to eq('localhost123')
      end

      it 'correctly retrieves simple paths' do
        expect(provider.get('instances')).to eq(4)
      end
    end

    context 'when base path is present' do
      let(:base_path) { 'application' }

      it 'correctly retrieves complex paths' do
        expect(provider.get('services/consul/domain')).to eq('localhost123')
      end

      it 'correctly retrieves simple paths' do
        expect(provider.get('enabled')).to eq(true)
      end
    end

    context 'when local file is absent' do
      let(:local_file_path) { '' }

      it 'correctly retrieves data' do
        expect(provider.get('application/services/consul/domain')).to eq('localhost')
      end
    end
  end

  context 'when YML file has invalid syntax' do
    let(:base_file_path) { fixture_path('invalid_syntax') }

    it 'raises error' do
      expect { provider.get(:a) }.to raise_error(SettingsReader::Error)
    end
  end
end
