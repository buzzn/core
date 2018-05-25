# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV['RACK_ENV'] = 'test'
ENV['LOG_LEVEL'] ||= 'warn' # can not set it in rails env as it is always 'error'
require File.expand_path('../../config/environment', __FILE__)
require 'rspec/rails'
require 'webmock/rspec'
require 'rspec/retry'
require 'awesome_print'

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir['./spec/support/**/*.rb'].each { |f| require f }

I18n.default_locale = :en

# we want randomness and reproduciblity, so set it here and any
# test can reset an initial state with Kernel.srand 0
class Array
  alias sample_old sample
  def sample(*)
    sample_old(random: Kernel)
  end
end
Kernel.srand 0

RSpec.configure do |config|

  config.nested_transaction do |example_or_group, run|
    (run[]; next) if example_or_group.class != Class || example_or_group.superclass != RSpec::Core::ExampleGroup || example_or_group.metadata[:skip_nested]

    # With ActiveRecord:
    ActiveRecord::Base.transaction(requires_new: true) do
      begin
        run[]
      ensure
        raise ActiveRecord::Rollback
      end
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
  config.order = 'random'

  # In Rspec 3.x the spec type is not automatically inferred from a file location, and you must manually set it
  config.infer_spec_type_from_file_location!

  # Include helpers
  config.include RequestsHelper, type: :request
  config.include PdfsHelper#, type: :pdfs

  def last_email
    ActionMailer::Base.deliveries.last
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

  def create(*args)
    FactoryGirl.create(*args)
  end

  def build(*args)
    FactoryGirl.build(*args)
  end

  def method_missing(method, *args)
    if self.respond_to?(:setup_entity)
      self.setup_entity(method) || super
    else
      super
    end
  end

  # show retry status in spec process
  config.verbose_retry = true
  # show exception that triggers a retry if verbose_retry is set to true
  config.display_try_failure_messages = true

  # Enable the :focus tag, but run all specs when no focus is set, or when running in CI (in case a :focus is forgotten in-code).
  # https://relishapp.com/rspec/rspec-core/v/2-6/docs/filtering/run-all-when-everything-filtered
  config.filter_run(focus: true) unless ENV['CI'].present?
  config.run_all_when_everything_filtered = true
end
