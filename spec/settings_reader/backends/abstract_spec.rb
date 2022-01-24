RSpec.describe SettingsReader::Backends::Abstract do
  let(:config) { instance_double(SettingsReader::Configuration) }
  let(:backend) { described_class.new('', config) }

  describe '#get' do
    it 'is not implemented' do
      expect { backend.get('test') }.to raise_exception(NotImplementedError)
    end
  end
end
