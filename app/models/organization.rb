class Organization < ContractingParty
  self.table_name = :organizations

  include Filterable

  belongs_to :address

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

  # Define some class-accessors for commonly used organizations (example: Organization.buzzn).
  # Note they are nil by default, need to be assigned from init code somewhere.
  PREDEFINED_ORGANIZATIONS = %i(buzzn germany discovergy)
  mattr_accessor(*PREDEFINED_ORGANIZATIONS)
  PREDEFINED_ORGANIZATIONS.each do |accessor|
    # Defines a predicate method, example: @organization.buzzn?
    define_method "#{accessor}?" do
      self == self.class.send(accessor)
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
