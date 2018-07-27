require_relative '../meter'

Schemas::Constraints::Meter::MeteringLocation = Schemas::Support.Form do
  required(:metering_location_id).filled(:str?, size?: 11)
end
