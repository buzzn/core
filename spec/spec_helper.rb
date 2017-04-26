# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] = 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'database_cleaner'
require 'vcr'
require 'webmock/rspec'
require 'rspec/retry'

require 'sidekiq/testing'
Sidekiq::Testing.fake!

# no geocoding for tests
class ::Address
  def geocode
  end
end

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

I18n.default_locale = :en


VCR.configure do |c|
  c.cassette_library_dir = "spec/vcr_cassettes"
  c.hook_into :faraday, :webmock
  c.default_cassette_options = { :serialize_with => :syck }
end


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

  # In Rspec 3.x the spec type is not automatically inferred from a file location, and you must manually set it
  config.infer_spec_type_from_file_location!

  # Include the requests helper
  config.include RequestsHelper, type: :request


  def last_email
    ActionMailer::Base.deliveries.last
  end

  config.before(:each) do
    Organization.constants.each do |c|
      name = c.to_s.downcase.to_sym
      if Organization.respond_to?(name) && name != :columns
        # reset cache
        Organization.instance_variable_set(:"@a_#{name}", nil)
        Organization.send(name) || Fabricate(name)
      end
    end
  end

  config.before(:context) do
    entities.clear
    DatabaseCleaner.clean_with(:truncation)
    DatabaseCleaner.start
  end

  config.after(:context) do
    puts '----> truncate DB'
    clean_database
  end
  
  def entities
    $entities ||= {}
  end

  def clean_manually
    BankAccount.delete_all
    Organization.delete_all
    User.delete_all
    Register::Base.delete_all
    Group::Base.delete_all
    Broker::Base.delete_all
    Meter::Base.delete_all
  end

  def clean_database
    DatabaseCleaner.clean

    if Register::Base.count + Group::Base.count + Broker::Base.count + Meter::Base.count > 0
      warn '-' * 80
      warn 'DB cleaner failed - cleaning manually'
      warn '-' * 80
      clean_manually
    end
  end

  def needs_cleaning?(spec)
    ! spec.metadata[:file_path].include?('requests') && ! spec.metadata[:file_path].include?('resources') && ! spec.metadata[:file_path].include?('services')
  end

  config.before(:each) do |spec|
    DatabaseCleaner.strategy = spec.description =~ /threaded/ ? :truncation : :transaction  # 'threaded' in description triggers a different DatabaseCleanet strategy
    if needs_cleaning?(spec)
      clean_database
      DatabaseCleaner.start
    end
  end

  config.append_after(:each) do |spec|
    Timecop.travel(Time.local(2016, 7, 2, 10, 5, 0)) # HACK https://github.com/buzzn/buzzn/blob/master/config/environments/test.rb#L43-L44 is not working
    Mongoid.purge!
    Redis.current.flushall
    Rails.cache.clear
    if needs_cleaning?(spec)
      clean_database
    end
  end


  # show retry status in spec process
  config.verbose_retry = true
  # show exception that triggers a retry if verbose_retry is set to true
  config.display_try_failure_messages = true

  # run retry only on features
  config.around :each, :js do |ex|
    ex.run_with_retry retry: 3
  end

end
