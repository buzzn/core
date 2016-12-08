require 'buzzn/guarded_crud'
require 'buzzn/managed_roles'
class Organization < ActiveRecord::Base
  resourcify
  include Buzzn::GuardedCrud
  extend FriendlyId

  friendly_id :name, use: [:slugged, :finders]

  include Authority::Abilities
  include Filterable
  include Buzzn::ManagerRole
  include Buzzn::MemberRole

  acts_as_taggable_on :contract_types

  mount_uploader :image, PictureUploader

  has_one  :contracting_party

  has_one :address, as: :addressable, dependent: :destroy
  accepts_nested_attributes_for :address, reject_if: :all_blank

  has_one :iln

  validates :name, presence: true, length: { in: 3..40 }, uniqueness: true
  validates :email, presence: true
  validates_format_of :email, :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i
  validates :phone, presence: true
  validates :mode, presence: true

  delegate :contracts, to: :contracting_party, allow_nil: true

  after_create :create_contracting_party

  scope :power_givers,                  -> { where(mode: 'power_giver') }
  scope :power_takers,                  -> { where(mode: 'power_taker') }
  scope :electricity_suppliers,         -> { where(mode: 'electricity_supplier') }
  scope :metering_service_providers,    -> { where(mode: 'metering_service_provider') }
  scope :metering_point_operators,      -> { where(mode: 'metering_point_operator') }
  scope :distribution_system_operators, -> { where(mode: 'distribution_system_operator') }
  scope :transmission_system_operators, -> { where(mode: 'transmission_system_operator') }
  scope :others,                        -> { where(mode: 'other') }
  scope :readable_by,                   -> (user) { where(nil) }


  # define some predefined organziation with cache
  { dummy: 'dummy organization',
    dummy_energy: 'dummy energy supplier',
    buzzn_reader: 'buzzn Reader',
    buzzn_energy: 'buzzn GmbH',
    buzzn_systems: 'buzzn systems UG',
    discovergy: 'Discovergy',
    mysmartgrid: 'MySmartGrid' }.each do |key, name|

    const_set key.to_s.upcase, name

    define_method "#{key.to_s}?" do
      self.name == "#{name}"
    end

    (class << self; self; end).instance_eval do
      define_method "#{key.to_s}" do
        eval "@a_#{key} ||= where(name: #{key.to_s.upcase}).first"
      end
    end
  end

  def self.modes
    %w{
      power_giver
      power_taker
      electricity_supplier
      metering_service_provider
      metering_point_operator
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

  private

  def create_contracting_party
    ContractingParty.create(legal_entity: 'company', organization: self)
  end

end
