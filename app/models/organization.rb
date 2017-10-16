# coding: utf-8
class Organization < ContractingParty
  self.table_name = :organizations

  include Filterable

  has_one :address, as: :addressable, dependent: :destroy

  has_many :energy_classifications

  belongs_to :contact, class_name: Person
  belongs_to :legal_representation, class_name: Person

  has_many :market_functions, dependent: :destroy, class_name: "OrganizationMarketFunction"

  def in_market_function(function)
    market_functions.find_by(function: function)
  end

  validates :name, presence: true, length: { in: 3..40 }, uniqueness: true
  validates :email, presence: true
  validates_format_of :email, :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i
  validates :phone, presence: true

  scope :permitted, ->(uuids) { where(nil) } # organizations are public

  # define some predefined organizations with cache
  {
    buzzn_energy: 'buzzn GmbH',
    buzzn_systems: 'buzzn systems UG',
    discovergy: 'Discovergy',
    mysmartgrid: 'MySmartGrid',
    germany: 'Germany Energy Mix',
    gemeindewerke_peissenberg: 'Gemeindewerke Peißenberg'
  }.each do |key, name|

    # Example: BUZZN_ENERGY = 'buzzn GmbH'
    const_set key.to_s.upcase, name

    # Example: def buzzn_energy?
    define_method "#{key.to_s}?" do
      self.name == "#{name}"
    end

    (class << self; self; end).instance_eval do
      # Example: def buzzn_energy
      define_method(key) do
        where(name: name).first
      end
    end
  end

  def self.search_attributes
    # FIXME: clarify if we need to be able to search by mode here.
    [:name, :email, :website, :description, address: [:city, :zip, :street]]
  end

  def self.filter(value)
    do_filter(value, *search_attributes)
  end
end
