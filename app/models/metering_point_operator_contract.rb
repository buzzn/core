class MeteringPointOperatorContract < ActiveRecord::Base
  belongs_to :organization
  belongs_to :metering_point
  belongs_to :group

  validates :organization, presence: true
  validates :username, presence: true, if: :login_required?
  validates :password, presence: true, if: :login_required?

  scope :running, -> { where(running: :true) }

  after_save :validates_credentials

  def login_required?
    if self.organization.nil?
      false
    else
      self.organization.slug == 'discovergy'
    end
  end


  def validates_credentials
    if self.organization.slug == 'discovergy' || self.organization.slug == 'buzzn-metering'
      api_call = Discovergy.new(self.username, self.password).meters
      if api_call['status'] == 'ok'
        self.update_columns(valid_credentials: true)
        validates_meters
      else
        self.update_columns(valid_credentials: false)
      end
    end
  end


private
  def validates_meters
    if group
      group.metering_points.each do |metering_point|
        metering_point.meter.save
      end
    end
    if metering_point
      metering_point.meter.save
    end
  end


end
