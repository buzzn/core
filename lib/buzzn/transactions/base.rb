require_relative '../transactions'

class Transactions::Base
  include Dry::Transaction(container: Buzzn::Boot::MainContainer)

  class << self

    def new(**)
      if ['call', 'for', 'with_step_args'].include? caller_locations[0].label
        super
      else
        raise NoMethodError.new("#{caller_locations[0]}: semi private method 'new' called for #{self}")
      end
    end

    def call(*args)
      new.call(*args)
    end

    def for(schema = nil, subject = nil, *steps)
      args = {}
      args[:validate] = [schema] if schema
      if subject
        arg = [subject]
        steps.each { |s| args[s] = arg }
      end
      new.with_step_args(args)
    end
  end
end
