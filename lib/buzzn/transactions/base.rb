require_relative '../transactions'

class Transactions::Base
  include Dry::Transaction(container: Buzzn::Boot::MainContainer)

  class << self

    def new(**)
      if ['create', 'with_step_args'].include? caller_locations[0].label
        super
      else
        raise NoMethodError.new("#{caller_locations[0]}: semi private method 'new' called for #{self}")
      end
    end

    def create(*)
      raise 'not implemented'
    end
  end
end
