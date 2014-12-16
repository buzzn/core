class MeteringPointUser < ActiveRecord::Base
  belongs_to :metering_point
  belongs_to :user

end
