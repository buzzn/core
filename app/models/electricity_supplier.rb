class ElectricitySupplier < ActiveRecord::Base
  belongs_to :organization
  belongs_to :metering_point
  has_paper_trail
end
