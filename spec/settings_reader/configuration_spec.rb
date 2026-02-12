RSpec.describe SettingsReader::Configuration do
  describe '#initialize' do
    context 'with default values' do
      let(:config) { described_class.new }

      it 'sets resolvers to Env resolver by default' do
        expect(config.resolvers.size).to eq(1)
        expect(config.resolvers.first).to be_a(SettingsReader::Resolvers::Env)
      end

      context 'when RAILS_ENV is not set' do
        before { stub_const('ENV', ENV.to_hash.except('RAILS_ENV')) }

        let(:config) { described_class.new }

        it 'creates yaml backends from default paths' do
          expect(config.backends.size).to eq(2)
          expect(config.backends).to all(be_a(SettingsReader::Backends::YamlFile))
        end
      end

      context 'when RAILS_ENV is set' do
        before { stub_const('ENV', ENV.to_hash.merge('RAILS_ENV' => 'test')) }

        let(:config) { described_class.new }

        it 'creates yaml backends including environment specific paths' do
          expect(config.backends.size).to eq(4)
          expect(config.backends).to all(be_a(SettingsReader::Backends::YamlFile))
        end
      end
    end

    context 'with custom values' do
      let(:custom_backend) { instance_double(SettingsReader::Backends::Abstract) }
      let(:custom_resolver) { instance_double(SettingsReader::Resolvers::Abstract) }
      let(:config) { described_class.new(backends: [custom_backend], resolvers: [custom_resolver]) }

      it 'sets custom backends' do
        expect(config.backends).to eq([custom_backend])
      end

      it 'sets custom resolvers' do
        expect(config.resolvers).to eq([custom_resolver])
      end
    end
  end

  describe '#backends=' do
    let(:config) { described_class.new }
    let(:custom_backend) { instance_double(SettingsReader::Backends::Abstract) }

    it 'allows setting backends after initialization' do
      config.backends = [custom_backend]
      expect(config.backends).to eq([custom_backend])
    end
  end

  describe '#resolvers=' do
    let(:config) { described_class.new }
    let(:custom_resolver) { instance_double(SettingsReader::Resolvers::Abstract) }

    it 'allows setting resolvers after initialization' do
      config.resolvers = [custom_resolver]
      expect(config.resolvers).to eq([custom_resolver])
    end
  end
end
