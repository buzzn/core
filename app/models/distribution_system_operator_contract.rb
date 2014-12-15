class DistributionSystemOperatorContract < ActiveRecord::Base
  belongs_to :organization
  belongs_to :metering_point

  default_scope -> { order(:created_at => :desc) }
end
