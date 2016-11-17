require 'buzzn/guarded_crud'
class Organization < ActiveRecord::Base
  resourcify
  include Buzzn::GuardedCrud
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

  validates :name, presence: true, length: { in: 3..40 }, uniqueness: true
  validates :email, presence: true
  validates_format_of :email, :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i
  validates :phone, presence: true
  validates :mode, presence: true

  scope :power_givers,                  -> { where(mode: 'power_giver') }
  scope :power_takers,                  -> { where(mode: 'power_taker') }
  scope :electricity_suppliers,         -> { where(mode: 'electricity_supplier') }
  scope :metering_service_providers,    -> { where(mode: 'metering_service_provider') }
  scope :register_operators,      -> { where(mode: 'register_operator') }
  scope :distribution_system_operators, -> { where(mode: 'distribution_system_operator') }
  scope :transmission_system_operators, -> { where(mode: 'transmission_system_operator') }
  scope :others,                        -> { where(mode: 'other') }
  scope :readable_by,                   -> (user) { where(nil) }

  DUMMY_ENERGY   = 'dummy energy supplier'
  BUZZN_ENERGY   = 'buzzn GmbH'
  BUZZN_READER   = 'buzzn Reader'
  BUZZN_METERING = 'buzzn systems UG'

  def self.dummy_energy
    where(name: DUMMY_ENERGY).first
  end

  def self.buzzn_energy
    where(name: BUZZN_ENERGY).first
  end

  def self.buzzn_reader
    where(name: BUZZN_READER).first
  end

  def self.buzzn_metering
    where(name: BUZZN_METERING).first
  end

  def buzzn_energy?
    name == BUZZN_ENERGY
  end

  def buzzn_reader?
    name == BUZZN_READER
  end

  def buzzn_metering?
    name == BUZZN_METERING
  end

  def self.modes
    %w{
      power_giver
      power_taker
      electricity_supplier
      metering_service_provider
      register_operator
      distribution_system_operator
      transmission_system_operator
      other
    }
  end

  def self.search_attributes
    [:name, :mode, :email, :website, :description, address: [:city, :state, :street_name]]
  end

  def self.filter(value)
    do_filter(value, *search_attributes)
  end
end
