require_relative 'filterable'
require_relative 'organization_market_function'

class Organization < ActiveRecord::Base

  self.table_name = :organizations

  include Filterable

  belongs_to :address
  belongs_to :contact, class_name: 'Person'
  belongs_to :legal_representation, class_name: 'Person'
  belongs_to :customer_number, foreign_key: :customer_number

  has_many :bank_accounts, foreign_key: :owner_organization_id
  has_many :energy_classifications
  has_many :market_functions, dependent: :destroy, class_name: 'OrganizationMarketFunction'

  before_create do
    self.slug ||= Buzzn::Slug.new(self.name)
  end

  # make a scope for each possible market function
  OrganizationMarketFunction.functions.keys.each do |function|
    send :scope, function, -> {
      where(id: OrganizationMarketFunction.send(function).select(:organization_id))
    }
  end

  def in_market_function(function)
    market_functions.find_by(function: function)
  end

  scope :permitted, ->(uids) { where(nil) } # organizations are public

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

  def self.reset_cache
    instance_variables.select { |n| n =~ /@a_/ }.each { |n| instance_variable_set(n, nil) }
  end

  def self.search_attributes
    [:name, :email, :website, :description, address: [:city, :zip, :street]]
  end

  def self.filter(value)
    do_filter(value, *search_attributes)
  end

  def to_s
    name
  end

end
