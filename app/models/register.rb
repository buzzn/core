class Register < ActiveRecord::Base
  include Filterable
  include Buzzn::GuardedCrud

  belongs_to :metering_point
  belongs_to :meter
  has_many :readings
end
