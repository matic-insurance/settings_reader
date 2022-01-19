RSpec.describe SettingsReader::Utils do
  let(:utils, &method(:described_class))

  describe '#cast_value_from_string' do
    it 'casts nil' do
      expect(utils.cast_value_from_string(nil)).to eq(nil)
    end

    it 'casts false boolean' do
      expect(utils.cast_value_from_string('false')).to eq(false)
    end

    it 'casts true boolean' do
      expect(utils.cast_value_from_string('true')).to eq(true)
    end

    it 'preserves hash' do
      value = { a: 1, b: '2' }
      expect(utils.cast_value_from_string(value)).to eq(value)
    end

    it 'casts arrays to hash with values casting' do
      value = [{ key: 'a', value: '1' }, { key: 'b', value: 'false' }]
      expect(utils.cast_value_from_string(value)).to eq({ 'a' => 1, 'b' => false })
    end

    it 'casts integers' do
      expect(utils.cast_value_from_string('123')).to eq(123)
    end

    it 'casts floats' do
      expect(utils.cast_value_from_string('1.23')).to eq(1.23)
    end

    it 'casts jsons' do
      expect(utils.cast_value_from_string('{"a": 1}')).to eq({ 'a' => 1 })
    end
  end

  describe '#generate_path' do
    it 'support single part' do
      expect(utils.generate_path('a')).to eq('a')
    end

    it 'joins two parts' do
      expect(utils.generate_path('a', 'b')).to eq('a/b')
    end

    it 'joins multiple parts' do
      expect(utils.generate_path('a', 'b/c', 'd')).to eq('a/b/c/d')
    end

    it 'removes starting slash' do
      expect(utils.generate_path('/a', 'b')).to eq('a/b')
    end

    it 'removes ending slash' do
      expect(utils.generate_path('a', 'b/')).to eq('a/b')
    end

    it 'skips empty strings' do
      expect(utils.generate_path('', 'a', '', 'b')).to eq('a/b')
    end

    it 'removes duplicated slashes' do
      expect(utils.generate_path('a/', 'b')).to eq('a/b')
    end
  end

  describe '#decompose_path' do
    it 'splits path to parts' do
      expect(utils.decompose_path('a/b/c')).to eq(%w[a b c])
    end

    it 'skips duplicated slashes' do
      expect(utils.decompose_path('a//b/c')).to eq(%w[a b c])
    end

    it 'skips starting slash' do
      expect(utils.decompose_path('/a/b/c')).to eq(%w[a b c])
    end

    it 'removes ending slash' do
      expect(utils.decompose_path('/a/b/c/')).to eq(%w[a b c])
    end
  end
end
