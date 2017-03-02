module Group
  class Localpool < Base

    has_one  :metering_point_operator_contract, class_name: Contract::MeteringPointOperator, foreign_key: :localpool_id
    has_one  :localpool_processing_contract,    class_name: Contract::LocalpoolProcessing, foreign_key: :localpool_id

  end
end
