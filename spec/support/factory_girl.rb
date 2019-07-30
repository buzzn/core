require 'factory_girl'

# factories are also used to generate seed data, that's why they're not in the spec folder.
FactoryGirl.definition_file_paths = %w(db/factories)
FactoryGirl.find_definitions

RSpec.configure do |config|
  config.include FactoryGirl::Syntax::Methods
end
