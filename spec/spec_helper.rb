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

  config.before(:all) do
    Organization.constants.each do |c|
      name = c.to_s.downcase.to_sym
      if Organization.respond_to? name
        Organization.send(name) || Fabricate(name)
      end
    end

    if Bank.count == 0
      Bank.update_from(File.read("db/banks/BLZ_20160606.txt"))
    end

    if ZipKa.count == 0
      csv_dir = 'db/csv'
      zip_vnb = File.read(File.join(csv_dir, "plz_vnb_test.csv"))
      zip_ka = File.read(File.join(csv_dir, "plz_ka_test.csv"))
      nne_vnb = File.read(File.join(csv_dir, "nne_vnb.csv"))
      ZipKa.from_csv(zip_ka)
      ZipVnb.from_csv(zip_vnb)
      NneVnb.from_csv(nne_vnb)
    end

    class ::Address
      def geocode
      end
    end
  end

  config.before(:suite) do
    DatabaseCleaner.clean_with(:truncation)
  end

  config.before(:each) do |spec|
    # 'threaded' in description triggers a different DatabaseCleanet strategy
    DatabaseCleaner.strategy = spec.description =~ /threaded/ ? :truncation : :transaction
  end

  config.before(:each, :js => true) do
    DatabaseCleaner.strategy = :truncation
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
    Mongoid.purge!
    Rails.cache.clear
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
