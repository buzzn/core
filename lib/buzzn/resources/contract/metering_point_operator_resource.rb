require_relative 'localpool_resource'

module Contract
  class MeteringPointOperatorResource < LocalpoolResource

    model MeteringPointOperator

    attributes :metering_point_operator_name
  end
end
