require_relative 'base_resource'

module Contract
  class MeteringPointOperatorResource < BaseResource

    model MeteringPointOperator

    attributes  :metering_point_operator_name
  end
end
