class Organization < ActiveRecord::Base
  extend FriendlyId
  friendly_id :name, use: [:slugged, :finders]
  include Authority::Abilities

  acts_as_taggable_on :contract_types

  has_many :distribution_system_operator_contracts
  has_many :electricity_supplier_contracts
  has_many :metering_service_provider_contracts
  has_many :metering_point_operator_contract

  has_many :assets, -> { order("position ASC") }, as: :assetable, dependent: :destroy

  has_one  :contracting_party

  has_one :address, as: :addressable, dependent: :destroy
  accepts_nested_attributes_for :address, reject_if: :all_blank

  has_one :iln

  validates :name, presence: true, length: { in: 3..40 }
  validates :email, presence: true
  validates_format_of :email, :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i
  validates :phone, presence: true

  scope :electricity_suppliers,         -> { where(mode: 'electricity_supplier') }
  scope :metering_service_providers,    -> { where(mode: 'metering_service_provider') }
  scope :metering_point_operators,      -> { where(mode: 'metering_point_operator') }
  scope :distribution_system_operators, -> { where(mode: 'distribution_system_operator') }
  scope :transmission_system_operators, -> { where(mode: 'transmission_system_operator') }


  def self.modes
    %w{
      electricity_supplier
      metering_service_provider
      metering_point_operator
      distribution_system_operator
      transmission_system_operator
    }
  end

end
