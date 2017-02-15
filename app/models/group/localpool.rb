module Group
  class Localpool < Base


    after_save :validate_localpool

    def validate_localpool
      if self.contracts.metering_point_operators.empty?
       #@contract = MeteringPointOperatorContract.new(group: self, organization: Organization.buzzn_systems, username: 'team@localpool.de', password: 'Zebulon_4711')
      else
        @contract = self.contracts.metering_point_operators.first
      end
      #@contract.save
    end

  end
end
