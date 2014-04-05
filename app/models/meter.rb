class Meter < ActiveRecord::Base
  resourcify
  include Authority::Abilities

  extend FriendlyId
  friendly_id :uid, use: [:slugged, :finders]

  validates :uid,     presence: true, uniqueness: true

  normalize_attribute :uid, with: [:strip]

  belongs_to :contract
  
  has_many :external_contracts, as: :external_contractable
  accepts_nested_attributes_for :external_contracts, reject_if: :reject_external_contracts

  has_one :power_generator

  has_one :address, as: :addressable
  accepts_nested_attributes_for :address, :reject_if => :all_blank

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
