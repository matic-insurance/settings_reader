RSpec.describe SettingsReader::Providers::Abstract do
  let(:config) { instance_double(SettingsReader::Configuration) }
  let(:provider) { described_class.new('', config) }

  describe '#get' do
    it 'is not implemented' do
      expect { provider.get('test') }.to raise_exception(NotImplementedError)
    end
  end
end
