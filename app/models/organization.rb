class Organization < ActiveRecord::Base
  resourcify
  extend FriendlyId

  friendly_id :name, use: [:slugged, :finders]

  include Authority::Abilities
  include Filterable
  include ReplacableRoles

  acts_as_taggable_on :contract_types

  mount_uploader :image, PictureUploader

  has_many :contracts

  has_one  :contracting_party

  has_one :address, as: :addressable, dependent: :destroy
  accepts_nested_attributes_for :address, reject_if: :all_blank

  has_many :managers, -> { where roles:  { name: 'manager'} }, through: :roles, source: :users
  has_many :members, -> { where roles:  { name: 'member'} }, through: :roles, source: :users

  has_one :iln

  validates :name, presence: true, length: { in: 3..40 }
  validates :email, presence: true
  validates_format_of :email, :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i
  validates :phone, presence: true
  validates :mode, presence: true

  scope :electricity_suppliers,         -> { where(mode: 'electricity_supplier') }
  scope :metering_service_providers,    -> { where(mode: 'metering_service_provider') }
  scope :metering_point_operators,      -> { where(mode: 'metering_point_operator') }
  scope :distribution_system_operators, -> { where(mode: 'distribution_system_operator') }
  scope :transmission_system_operators, -> { where(mode: 'transmission_system_operator') }
  scope :readable_by,                   -> (user) { where(nil) }

  def self.modes
    %w{
      electricity_supplier
      metering_service_provider
      metering_point_operator
      distribution_system_operator
      transmission_system_operator
    }
  end

  def self.search_attributes
    [:name, :mode, :email, :website, :description, address: [:city, :state, :street_name]]
  end

  def self.filter(value)
    do_filter(value, *search_attributes)
  end
end
