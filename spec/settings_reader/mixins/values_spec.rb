RSpec.describe SettingsReader::Mixins::Values do
  include described_class

  describe '#cast_value_from_string' do
    it 'casts nil' do
      expect(cast_value_from_string(nil)).to eq(nil)
    end

    it 'casts false boolean' do
      expect(cast_value_from_string('false')).to eq(false)
    end

    it 'casts true boolean' do
      expect(cast_value_from_string('true')).to eq(true)
    end

    it 'preserves hash' do
      value = { a: 1, b: '2' }
      expect(cast_value_from_string(value)).to eq(value)
    end

    it 'casts arrays to hash with values casting' do
      value = [{ key: 'a', value: '1' }, { key: 'b', value: 'false' }]
      expect(cast_value_from_string(value)).to eq({ 'a' => 1, 'b' => false })
    end

    it 'casts integers' do
      expect(cast_value_from_string('123')).to eq(123)
    end

    it 'casts floats' do
      expect(cast_value_from_string('1.23')).to eq(1.23)
    end

    it 'casts jsons' do
      expect(cast_value_from_string('{"a": 1}')).to eq({ 'a' => 1 })
    end

    it 'casts strings' do
      expect(cast_value_from_string('{"abcde')).to eq('{"abcde')
    end
  end
end
