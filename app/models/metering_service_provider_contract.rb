class MeteringServiceProviderContract < ActiveRecord::Base
  belongs_to :organization
  belongs_to :metering_point


end
