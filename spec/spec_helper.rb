$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..'))
$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'database_cleaner'

# Set up RSpec
require 'rspec'
RSpec.configure do |config|
  config.before(:suite) do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with(:truncation)
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end
end

# Set up a testing envoronment and off we go
ENV['environment'] = 'test'
require 'lib/bluereader'

# Set up FactoryGirl
require 'factory_girl'
FactoryGirl.find_definitions