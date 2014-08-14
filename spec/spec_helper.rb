# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] = 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'

require 'capybara'
require 'capybara/dsl'
require 'capybara/rspec'
require 'capybara/poltergeist'
require 'capybara/rspec/matchers'
require 'capybara/rspec/features'
require 'database_cleaner'
require 'webmock/rspec'
require 'vcr'

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}



RSpec.configure do |config|
  # ## Mock Framework
  #
  # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr

  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  # config.fixture_path = "#{::Rails.root}/spec/fixtures"

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = false

  # If true, the base class of anonymous controllers will be inferred
  # automatically. This will be the default behavior in future versions of
  # rspec-rails.
  config.infer_base_class_for_anonymous_controllers = false

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = "random"


  # VCR
  VCR.configure do |config|
    config.cassette_library_dir       = 'spec/cassettes'
    config.hook_into                  :webmock
    config.configure_rspec_metadata!
    config.ignore_localhost           = true
  end






  Capybara.default_wait_time = 8 # Seconds to wait before timeout error. Default is 2

  # Register slightly larger than default window size...
  Capybara.register_driver :poltergeist do |app|
    Capybara::Poltergeist::Driver.new(app, { debug: true, # change this to true to troubleshoot
                                             window_size: [1440, 900] # this can affect dynamic layout
    })
  end
  Capybara.javascript_driver = :poltergeist

  def render_page(name)
    png_name = name.strip.gsub(/\W+/, '-')
    path = File.join(Rails.application.config.integration_test_render_dir, "#{png_name}.png")
    page.driver.render(path)
  end

  # shortcut for typing save_and_open_page
  def page!
    save_and_open_page
  end





  config.before(:suite) do
    DatabaseCleaner.clean_with(:truncation)
  end

  config.before(:each) do
    DatabaseCleaner.strategy = :transaction
  end

  config.before(:each, :js => true) do
    DatabaseCleaner.strategy = :truncation
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end

end
