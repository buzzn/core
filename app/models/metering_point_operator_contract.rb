class MeteringPointOperatorContract < ActiveRecord::Base
  after_save :validates_smartmeter

  belongs_to :organization
  belongs_to :metering_point
  belongs_to :group

  def validates_smartmeter
    if self.organization.slug == 'discovergy' || self.organization.slug == 'buzzn_metering'
      self.metering_point.validates_smartmeter
    end
  end
end
