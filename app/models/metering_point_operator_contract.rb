class MeteringPointOperatorContract < ActiveRecord::Base
  after_save :validates_smartmeter

  belongs_to :organization
  belongs_to :metering_point
  belongs_to :group

  validates :organization, presence: true
  validates :username, presence: true, if: :login_required?
  validates :password, presence: true, if: :login_required?

  def login_required?
    if self.organization.nil?
      false
    else
      self.organization.slug == 'discovergy'
    end
  end

  def validates_smartmeter
    if self.metering_point
      if self.organization.slug == 'discovergy' || self.organization.slug == 'buzzn-metering'
        self.metering_point.validates_smartmeter
      end
    elsif self.group
      if self.organization.slug == 'discovergy' || self.organization.slug == 'buzzn-metering'
        self.group.metering_points.each do |metering_point|
          metering_point.validates_smartmeter
        end
      end
    end
  end
end
