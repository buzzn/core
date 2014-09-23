class MeteringPointOperatorContract < ActiveRecord::Base
  belongs_to :organization
  belongs_to :metering_point
  belongs_to :group
end
