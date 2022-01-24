RSpec.describe SettingsReader, :performance do
  describe 'Load performance' do
    it 'is faster then 0.1ms for one read' do
      settings = testing_settings
      execution_time = Benchmark.measure { 1000.times { settings.get('application/name') } }
      expect(execution_time.real).to be < 0.1
    end

    it 'is faster then 20ms for load' do
      execution_time = Benchmark.measure { 100.times { testing_settings } }
      expect(execution_time.real).to be < 2
    end
  end
end
