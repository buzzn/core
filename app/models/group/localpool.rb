module Group
  class Localpool < Base

    has_one  :metering_point_operator_contract, class_name: Contract::MeteringPointOperator, foreign_key: :localpool_id
    has_one  :localpool_processing_contract,    class_name: Contract::LocalpoolProcessing, foreign_key: :localpool_id

    has_many :addresses, as: :addressable, dependent: :destroy

    # use first address as main address
    # maybe improve this so that the user can select between all addresses
    def main_address
      self.addresses.order("created_at ASC").first
    end

  end
end
