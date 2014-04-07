class Meter < ActiveRecord::Base
  resourcify
  include Authority::Abilities

  extend FriendlyId
  friendly_id :uid, use: [:slugged, :finders]

  validates :uid, presence: true, uniqueness: true

  normalize_attribute :uid, with: [:strip]

  belongs_to :metering_point

  has_one :power_generator

  def reject_external_contracts(attributed)
    attributed['customer_number'].blank? && attributed['contract_number'].blank?
  end

  def day_to_hours
    hours = []
    Reading.this_day_to_hours_by_meter_id(self.id).each do |hour|
      hours << hour['hourReading']
    end

    return hours.join(', ')
  end


end
