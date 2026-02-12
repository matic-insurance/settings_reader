RSpec.describe SettingsReader::Resolvers::Env do
  subject(:resolver) { described_class.new }

  let(:path) { 'application/hostname' }

  describe '#resolvable?' do
    it 'returns true when starts with env://' do
      expect(resolver).to be_resolvable('env://TEST_URL', path)
    end

    it 'returns false for nil' do
      expect(resolver).not_to be_resolvable(nil, path)
    end

    it 'returns false for other strings' do
      expect(resolver).not_to be_resolvable('envTEST_URL', path)
    end

    it 'returns false for int' do
      expect(resolver).not_to be_resolvable(1, path)
    end
  end

  describe '#resolve' do
    it 'returns env value' do
      stub_const('ENV', ENV.to_hash.merge('TEST_URL' => 'resolved'))
      expect(resolver.resolve('env://TEST_URL', path)).to eq('resolved')
    end

    it 'returns nil when env missing' do
      expect(resolver.resolve('env://TEST_URL', path)).to be_nil
    end

    context 'with invalid input' do
      it 'returns using whole value when prefix missing' do
        stub_const('ENV', ENV.to_hash.merge('TEST_URL' => 'resolved'))
        expect(resolver.resolve('TEST_URL', path)).to eq('resolved')
      end

      it 'converts to string' do
        stub_const('ENV', ENV.to_hash.merge('123' => 'resolved'))
        expect(resolver.resolve(123, path)).to eq('resolved')
      end
    end
  end
end
