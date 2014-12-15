class MeteringPointUser < ActiveRecord::Base
  belongs_to :metering_point
  belongs_to :user

  default_scope -> { order(:created_at => :desc) }
end
