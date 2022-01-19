RSpec.describe SettingsReader::Resolvers::Abstract do
  subject(:resolver) { described_class.new }

  let(:value) { [true, 'env://eeee', 1, nil].sample }
  let(:path) { 'test/call' }

  it 'do not resolve value any value' do
    expect(resolver).not_to be_resolvable(value, path)
  end

  it 'returns original value' do
    expect(resolver.resolve(value, path)).to eq(value)
  end
end
