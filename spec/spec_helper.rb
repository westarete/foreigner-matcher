require 'yaml'
require 'active_record'
require 'foreigner-matcher'
require 'rails/railtie'
require 'foreigner'

# Open a database connection
db_config_yml = File.dirname(__FILE__)
db_config_yml << '/../ci' if ENV['TRAVIS']
db_config_yml << '/config/database.yml'
db_configs = YAML::load(File.open(db_config_yml))
db_adapter = ENV['DB']
db_adapter = 'jdbc-' + db_adapter if RUBY_PLATFORM == 'java'
db_config  = db_configs[db_adapter]
ActiveRecord::Base.configurations = db_configs
ActiveRecord::Base.establish_connection(db_config)

Foreigner::Railtie.instance.run_initializers

# Requires supporting files with custom matchers and macros, etc,
# in ./support/ and its subdirectories.
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}

# Configure rspec options
RSpec.configure do |config|
  config.mock_framework = :mocha

  config.include(ConnectionHelpers)
  config.include(ForeignKeyDefinitionHelpers)
end
