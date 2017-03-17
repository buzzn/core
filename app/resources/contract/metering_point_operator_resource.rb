module Contract
  class MeteringPointOperatorSerializer < ActiveModel::Serializer

    attributes  :begin_date,
                :metering_point_operator_name

  end
end
