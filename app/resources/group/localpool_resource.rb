module Group
  class LocalpoolResource < MinimalBaseResource

    model Group::Localpool

    has_one :localpool_processing_contract
    has_one :metering_point_operator_contract

  end
end
