RSpec.describe SettingsReader::Reader do
  let(:config) { testing_config }
  let(:reader) { described_class.new('', config) }

  context 'with default backends' do
    describe '#get' do
      it 'gets value from file' do
        expect(reader.get('application/name')).to eq('NestedStructure')
      end

      it 'returns nil if the key does not exist' do
        expect(reader.get('application/key')).to eq(nil)
      end

      it 'raises error when reading tree' do
        err = %r{Getting value of complex object at path: 'application/services'}
        expect { reader.get('application/services') }.to raise_error(SettingsReader::Error, err)
      end
    end

    describe '#blank?' do
      it 'returns false when existing values are loaded' do
        expect(reader.load('instances').blank?).to eq(false)
      end

      it 'returns true when unexisting values are loaded' do
        expect(reader.load('unexisting').blank?).to eq(true)
      end
    end

    describe '#present?' do
      it 'returns true when existing values are loaded' do
        expect(reader.load('instances').present?).to eq(true)
      end

      it 'returns false when unexisting values are loaded' do
        expect(reader.load('unexisting').present?).to eq(false)
      end
    end
  end

  context 'with custom backend' do
    let(:backend) { instance_double(SettingsReader::Backends::Abstract) }

    before do
      config.backends = [
        backend,
        SettingsReader::Backends::YamlFile.new(fixture_path('base_application_settings'))
      ]
      allow(backend).to receive(:get).and_return(nil)
      allow(backend).to receive(:get).with('application/services/consul/domain').and_return('my.domain')
    end

    describe '#get' do
      it 'gets value from custom backend if it exists' do
        expect(reader.get('application/services/consul/domain')).to eq('my.domain')
      end

      it 'gets value from file if it does not exist in custom backend' do
        expect(reader.get('application/name')).to eq('NestedStructure')
      end

      it 'returns nil if the key does not exist' do
        expect(reader.get('application/key')).to eq(nil)
      end
    end

    describe '#blank?' do
      it 'returns false when existing values are loaded' do
        expect(reader.load('instances').blank?).to eq(false)
      end

      it 'returns true when unexisting values are loaded' do
        expect(reader.load('unexisting').blank?).to eq(true)
      end
    end

    describe '#present?' do
      it 'returns true when existing values are loaded' do
        expect(reader.load('instances').present?).to eq(true)
      end

      it 'returns false when unexisting values are loaded' do
        expect(reader.load('unexisting').present?).to eq(false)
      end
    end
  end

  context 'when new load' do
    let(:reader) { described_class.new('', config).load('application') }

    before do
      set_custom_value('application/services/consul/domain', '0.0.0.0')
    end

    describe '#get' do
      it 'gets custom value from first backend' do
        expect(reader.get('services/consul/domain')).to eq('0.0.0.0')
      end

      it 'gets value from file if it does not exist in first backend' do
        expect(reader.get('name')).to eq('NestedStructure')
      end

      it 'returns nil if the key does not exist' do
        expect(reader.get('application/key')).to eq(nil)
      end
    end
  end

  context 'with custom resolvers' do
    let(:resolver) do
      resolver = instance_double(SettingsReader::Resolvers::Abstract)
      allow(resolver).to receive(:resolvable?).with('please_resolve', anything).and_return(true)
      allow(resolver).to receive(:resolvable?).with('NestedStructure', anything).and_return(true)
      allow(resolver).to receive(:resolvable?).with(anything, 'application/services/consul/domain').and_return(false)
      allow(resolver).to receive(:resolve).and_return('resolved')
      resolver
    end

    before do
      config.resolvers = [resolver]
      set_custom_value('application/key', 'please_resolve')
    end

    describe '#get' do
      it 'resolves value from local config' do
        expect(reader.get('application/name')).to eq('resolved')
      end

      it 'resolves value from custom backend' do
        expect(reader.get('application/key')).to eq('resolved')
      end

      it 'return original if not resolvable' do
        expect(reader.get('application/services/consul/domain')).to eq('localhost')
      end

      it 'returns resolves key with value and path' do
        reader.get('application/key')
        expect(resolver).to have_received(:resolve).with('please_resolve', 'application/key')
      end
    end
  end
end
