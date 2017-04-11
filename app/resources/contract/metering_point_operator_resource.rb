module Contract
  class MeteringPointOperatorResource < BaseResource

    model MeteringPointOperator

    attributes  :begin_date,
                :metering_point_operator_name

  end

  # TODO get rid of the need of having a Serializer class
  class MeteringPointOperatorSerializer < MeteringPointOperatorResource
  end
end
