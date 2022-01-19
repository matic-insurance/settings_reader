RSpec.describe SettingsReader::Reader do
  let(:config) { SettingsReader.config }
  let(:reader) { described_class.new('', config) }

  context 'default providers' do
    describe '#get' do
      it 'gets value from file' do
        expect(reader.get('application/name')).to eq('NestedStructure')
      end

      it 'returns nil if the key does not exist' do
        expect(reader.get('application/key')).to eq(nil)
      end

      it 'raising error when reading tree' do
        err = %r{Getting value of complex object at path: 'application/services'}
        expect { reader.get('application/services') }.to raise_error(SettingsReader::Error, err)
      end
    end
  end

  context 'with custom provider' do
    let(:reader) { described_class.new('', config) }
    let(:provider_class) { double('CustomProvider', new: provider) }
    let(:provider) { instance_double(SettingsReader::Providers::Abstract) }
    before do
      config.settings_providers = [
        provider_class,
        SettingsReader::Providers::LocalStorage
      ]
    end

    before do
      allow(provider).to receive(:get).and_return(nil)
      allow(provider).to receive(:get).with('application/services/consul/domain').and_return('my.domain')
    end

    describe '.initialize' do
      it 'creates custom provider' do
        reader
        expect(provider_class).to have_received(:new).with('', config)
      end
    end

    describe '#get' do
      it 'gets value from consul if it exists' do
        expect(reader.get('application/services/consul/domain')).to eq('my.domain')
      end

      it 'gets value from file if it does not exist in Consul' do
        expect(reader.get('application/name')).to eq('NestedStructure')
      end

      it 'returns nil if the key does not exist' do
        expect(reader.get('application/key')).to eq(nil)
      end
    end
  end

  context 'new load' do
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

  context 'custom resolvers' do
    let(:reader) { described_class.new('', config) }
    let(:resolver_class) { class_double(SettingsReader::Resolvers::Abstract, new: resolver) }
    let(:resolver) do
      resolver = instance_double(SettingsReader::Resolvers::Abstract)
      allow(resolver).to receive(:resolvable?).with('please_resolve', anything).and_return(true)
      allow(resolver).to receive(:resolvable?).with('NestedStructure', anything).and_return(true)
      allow(resolver).to receive(:resolvable?).with(anything, 'application/services/consul/domain').and_return(false)
      allow(resolver).to receive(:resolve).and_return('resolved')
      resolver
    end

    before do
      config.value_resolvers = [resolver_class]
      set_custom_value('application/key', 'please_resolve')
    end

    describe '#get' do
      it 'resolves value from local config' do
        expect(reader.get('application/name')).to eq('resolved')
      end

      it 'resolves value from consul' do
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
