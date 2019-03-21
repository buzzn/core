require_relative '../admin'

class Transactions::Admin::Meter < Transactions::Base
  def create_or_find_metering_point_id(params:, **)
    metering_location_id = params.delete(:metering_location_id)
    if metering_location_id
      params[:metering_location] = Meter::MeteringLocation.find_by_metering_location_id(metering_location_id) ||
                                   Meter::MeteringLocation.create(metering_location_id: metering_location_id)
    end
  end
end
