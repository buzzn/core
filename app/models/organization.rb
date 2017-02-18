require 'buzzn/managed_roles'
class Organization < ContractingParty
  self.table_name = :organizations
  include Buzzn::GuardedCrud
  #extend FriendlyId

  #friendly_id :name, use: [:slugged, :finders]

  include Authority::Abilities
  include Filterable
  include Buzzn::ManagerRole
  include Buzzn::MemberRole

  # TODO what is this used for ?
  acts_as_taggable_on :contract_types

  mount_uploader :image, PictureUploader

  has_one :address, as: :addressable, dependent: :destroy
  accepts_nested_attributes_for :address, reject_if: :all_blank

  has_one :iln


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


  validates :name, presence: true, length: { in: 3..40 }, uniqueness: true
  validates :email, presence: true
  validates_format_of :email, :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i
  validates :phone, presence: true
  validates :mode, presence: true, inclusion: {in: modes}

  self.modes.each do |mode|
    scope mode, -> { where(mode: mode) }
  end

  scope :readable_by,                   -> (user) { where(nil) }


  # define some predefined organziation with cache
  { dummy: 'dummy organization',
    dummy_energy: 'dummy energy supplier',
    #TODO what is the buzzn-reader organization ???
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

  def self.search_attributes
    [:name, :mode, :email, :website, :description, address: [:city, :state, :street_name]]
  end

  def self.filter(value)
    do_filter(value, *search_attributes)
  end

end
