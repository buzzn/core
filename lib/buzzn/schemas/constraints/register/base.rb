require_relative 'common'

Schemas::Constraints::Register::Base = Schemas::Support.Form do
  optional(:metering_point_id).filled(:str?, max_size?: 64)
end
