RSpec.configure do |config|
  config.before(:each, :performance) do
    require 'benchmark'
  end
end
