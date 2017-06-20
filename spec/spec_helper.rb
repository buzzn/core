# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] = 'test'
ENV['LOG_LEVEL'] ||= 'info' # can not set it in rails env as it is always 'error'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
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

  config.nested_transaction do |example_or_group, run|
    (run[]; next) if example_or_group.class != Class || example_or_group.superclass != RSpec::Core::ExampleGroup

    # With ActiveRecord:
    ActiveRecord::Base.transaction(requires_new: true) do
      run[]
      raise ActiveRecord::Rollback
    end
  end

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

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = "random"

  # In Rspec 3.x the spec type is not automatically inferred from a file location, and you must manually set it
  config.infer_spec_type_from_file_location!

  # Include helpers
  config.include RequestsHelper, type: :request
  config.include PdfsHelper#, type: :pdfs

  def last_email
    ActionMailer::Base.deliveries.last
  end

  config.after(:context) do
    Mongoid.purge!
  end

  config.before(:context) do
    #Mongoid.purge!
    models = [Register::Base,  Group::Base, User, Broker::Base,  Meter::Base, Contract::Base, Reading, Contract::Tariff, Contract::Payment, BankAccount, Billing, BillingCycle, Comment, Device, Document, EnergyClassification, Organization, Price, Role, Score, Profile]
    if models.detect { |m| m.count > 0 }
      warn '-' * 80
      warn 'DB cleaning failed'
      models.each do |m|
        warn "#{m}: #{m.count}"
      end
      warn '-' * 80
    end
    Organization.constants.each do |c|
      name = c.to_s.downcase.to_sym
      if Organization.respond_to?(name) && name != :columns
        # reset cache
        Organization.instance_variable_set(:"@a_#{name}", nil)
        Organization.send(name) || Fabricate(name)
      end
    end
  end

  module ClassMethods
    def entity_blocks
      @entity_blocks ||= {}
    end

    def forced_entities
      @forced_entities ||= []
    end

    def entities
      @entities ||= {}
    end

    def setup_entities
      if superclass.respond_to? :setup_entities
        superclass.setup_entities
      end
      forced_entities.each do |key|
        setup_entity(key)
      end
    end

    def setup_entity(key)
      result = nil
      if superclass.respond_to? :setup_entity
        result = superclass.setup_entity(key)
      end
      if result.nil? && entity_blocks.key?(key)
        entities[key] ||= entity_blocks[key].call
      else
        result
      end
    end
  end

  module InstanceMethods
    def method_missing(method, *args)
      self.class.setup_entity(method) || super
    end
  end

  def entity(key, &block)
    unless self.kind_of?(InstanceMethods)
      self.send(:extend, ClassMethods)
      self.send(:include, InstanceMethods)
      self.class_eval do
        before do
          self.class.setup_entities
        end
      end
    end
    self.entity_blocks[key.to_sym] = block
  end

  def entity!(key, &block)
    entity(key, &block)
    self.forced_entities << key.to_sym
  end

  def method_missing(method, *args)
    if self.respond_to?(:setup_entity)
      self.setup_entity(method) || super
    else
      super
    end
  end

  def clean_manually
    BankAccount.delete_all
    Organization.delete_all
    Contract::Tariff.delete_all
    Contract::Payment.delete_all
    Contract::Base.delete_all
    User.delete_all
    Register::Base.delete_all
    Group::Base.delete_all
    Broker::Base.delete_all
    Meter::Base.delete_all
    Billing.delete_all
    BillingCycle.delete_all
    Mongoid.purge!
  end

  def clean_database
    if Register::Base.count + Group::Base.count + Broker::Base.count + Meter::Base.count + Reading.count > 0
      warn '-' * 80
      warn 'DB cleaner failed - cleaning manually'
      warn '-' * 80
      clean_manually
    end
  end

  config.append_after(:each) do |spec|
    Timecop.travel(Time.local(2016, 7, 2, 10, 5, 0)) # HACK https://github.com/buzzn/buzzn/blob/master/config/environments/test.rb#L43-L44 is not working
    Redis.current.flushall
    Rails.cache.clear
  end


  # show retry status in spec process
  config.verbose_retry = true
  # show exception that triggers a retry if verbose_retry is set to true
  config.display_try_failure_messages = true

end
