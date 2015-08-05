class MeteringPointSerializer < ActiveModel::Serializer
  attributes  :id,
              :uid,
              :name,
              :mode,
              :device_ids,
              :meter_id,
              :chart

  def chart
   return {
    :columns => [
      ['data1', 230, 190, 300, 500, 300, 400],
      ['data2', 50, 20, 10, 40, 15, 25]]
   }
  end

end
