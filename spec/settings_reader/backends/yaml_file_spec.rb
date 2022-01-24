RSpec.describe SettingsReader::Backends::YamlFile do
  let(:backend) { described_class.new(fixture_path('backend_tests')) }

  describe '#get' do
    context 'when path is correct' do
      it 'correctly retrieves deep paths' do
        expect(backend.get('root/level_2/level_3/level_4')).to eq('descendant_value')
      end

      it 'correctly retrieves simple paths' do
        expect(backend.get('foo')).to eq('bar')
      end
    end

    context 'when path is not correct' do
      it 'return nils on complex paths' do
        expect(backend.get('level_3/level_4')).to eq(nil)
      end

      it 'return nils on simple paths' do
        expect(backend.get('children')).to eq(nil)
      end
    end

    context 'when the key is a symbol' do
      it 'correctly retrieves data' do
        expect(backend.get(:foo)).to eq('bar')
      end
    end

    context 'when complex value' do
      it 'returns string values' do
        expect(backend.get('values/string')).to eq('a string')
      end

      it 'returns boolean values for true' do
        expect(backend.get('values/boolean_true')).to eq(true)
      end

      it 'returns boolean values for false' do
        expect(backend.get('values/boolean_false')).to eq(false)
      end

      it 'returns integer values' do
        expect(backend.get('values/integer')).to eq(123)
      end

      it 'returns float values' do
        expect(backend.get('values/float')).to eq(5.0)
      end

      it 'returns empty values' do
        expect(backend.get('values/empty')).to eq(nil)
      end

      it 'returns nil when missing' do
        expect(backend.get('missing')).to eq(nil)
      end

      it 'returns object values' do
        object = { 'level_2_child' => 'child_value', 'level_3' => { 'level_4' => 'descendant_value' } }
        expect(backend.get('root/level_2')).to eq(object)
      end

      it 'parsing object values' do
        object = { 'boolean_true' => true, 'float' => 5.0, 'integer' => 123, 'string' => 'a string' }
        expect(backend.get('values')).to include(object)
      end
    end
  end

  context 'when YML file incorrect' do
    it 'raises error on invalid syntax' do
      expect { described_class.new(fixture_path('invalid_syntax')) }.to raise_error(SettingsReader::Error)
    end

    it 'not raises error on missing file' do
      expect { described_class.new(fixture_path('file_missing')) }.not_to raise_error
    end
  end
end
