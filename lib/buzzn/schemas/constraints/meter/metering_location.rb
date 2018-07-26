require_relative '../meter'

Schemas::Constraints::Meter::MeteringLocation = Schemas::Support.Form do
  optional(:metering_location_id).filled(:str?, size?: 11)
end
