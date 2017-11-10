# factories are also used to generate seed data, that's why they're not in the spec folder.
FactoryGirl.definition_file_paths = %w(db/factories)

RSpec.configure do |config|
  config.include FactoryGirl::Syntax::Methods

  config.before(:suite) do
    FactoryGirl.find_definitions
  end
end
