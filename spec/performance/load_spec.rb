RSpec.describe 'Load Performance', :performance do
  describe 'performance', :default_settings_file do
    it 'should be faster then 0.1ms for one read' do
      settings = SettingsReader.load
      execution_time = Benchmark.measure { 1000.times { settings.get('application/name') } }
      expect(execution_time.real).to be < 0.1
    end

    it 'should be faster then 20ms for load' do
      execution_time = Benchmark.measure { 100.times { SettingsReader.load } }
      expect(execution_time.real).to be < 2
    end
  end
end