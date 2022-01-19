RSpec.describe SettingsReader::Resolvers::Erb do
  subject(:resolver) { described_class.new }

  let(:path) { 'application/hostname' }

  describe '#resolvable?' do
    it 'returns true when starts has erb' do
      expect(resolver).to be_resolvable('aaaa<%= 2 + 2 %>', path)
    end

    it 'returns false when has incorrect erb' do
      expect(resolver).not_to be_resolvable('aaaa<% 2 +', path)
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
    it 'evaluates erb' do
      expect(resolver.resolve('aaaa<%= 2 + 2 %>', path)).to eq('aaaa4')
    end

    it 'has access to env' do
      expect(resolver.resolve("<%= ENV['PATH'] %>", path)).to eq(ENV['PATH'])
    end

    context 'with invalid input' do
      it 'ignores incorrect erb' do
        expect(resolver.resolve('aaaa<%= 2 +', path)).to eq('aaaa 2 +')
      end

      it 'raising error for missing variable' do
        expect { resolver.resolve('<%= path %>', path) }.to raise_error(NameError)
      end

      it 'converts int to string' do
        expect(resolver.resolve(123, path)).to eq('123')
      end
    end
  end
end
