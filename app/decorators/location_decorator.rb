class LocationDecorator < Draper::Decorator
  delegate_all
  decorates_association :address
  decorates_association :metering_points
end
