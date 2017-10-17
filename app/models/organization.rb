class Organization < ContractingParty
  self.table_name = :organizations

  include Filterable

  belongs_to :address

  has_many :energy_classifications

  belongs_to :contact, class_name: Person
  belongs_to :legal_representation, class_name: Person

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

  scope :permitted, ->(uuids) { where(nil) } # organizations are public

  self.modes.each do |mode|
    scope mode + "s", -> { where(mode: mode) }
  end

  # define some predefined organziation with cache
  { dummy: 'dummy organization',
    dummy_energy: 'dummy energy supplier',
    buzzn_energy: 'buzzn GmbH',
    buzzn_systems: 'buzzn systems UG',
    discovergy: 'Discovergy',
    mysmartgrid: 'MySmartGrid',
    germany: 'Germany Energy Mix',
    gemeindewerke_peissenberg: 'Gemeindewerke Peißenberg' }.each do |key, name|

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
    [:name, :mode, :email, :website, :description, address: [:city, :zip, :street]]
  end

  def self.filter(value)
    do_filter(value, *search_attributes)
  end

end
