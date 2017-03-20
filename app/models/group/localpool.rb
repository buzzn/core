module Group
  class Localpool < Base

    def metering_point_operator_contract
      Contract::Base.find_by(localpool_id: self.id, type: 'Contract::MeteringPointOperator')
    end

    def localpool_processing_contract
      Contract::Base.find_by(localpool_id: self.id, type: 'Contract::LocalpoolProcessing')
    end

    has_many :addresses, as: :addressable, dependent: :destroy

    # use first address as main address
    # TODO: maybe improve this so that the user can select between all addresses
    def main_address
      self.addresses.order("created_at ASC").first
    end

  end
end
