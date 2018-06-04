require_relative 'localpool'

module Contract
  class MeteringPointOperator < Localpool

    after_initialize do
      self.contractor_organization = Organization.buzzn
    end

    def customer
      localpool&.owner
    end

    def customer=(*)
      raise 'can not assign customer as it is always localpool.owner'
    end

    def contractor=(*)
      raise 'can not assign contractor as it is always Organization.buzzn'
    end

  end
end
