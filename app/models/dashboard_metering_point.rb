class DashboardMeteringPoint < ActiveRecord::Base
  belongs_to :dashboard
  belongs_to :metering_point
end
