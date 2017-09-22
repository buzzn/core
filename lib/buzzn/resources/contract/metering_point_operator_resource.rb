module Contract
  class MeteringPointOperatorResource < BaseResource

    model MeteringPointOperator

    attributes  :begin_date,
                :metering_point_operator_name

    has_one :address
  end
end
