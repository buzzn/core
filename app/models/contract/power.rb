require_relative 'base'

module Contract
  class Power < Base
    # NOTE: having this in breaks the factories as type is not getting set.
    #self.abstract_class = true

    def initialize(*args)
      super
      self.contractor = Organization.buzzn
    end
  end
end
