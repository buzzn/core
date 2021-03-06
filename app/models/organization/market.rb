require_relative 'market_function'
require_relative 'base'

module Organization
  class Market < Base

    has_many :market_functions, dependent: :destroy, class_name: 'Organization::MarketFunction', foreign_key: :organization_id
    has_many :energy_classifications, foreign_key: :organization_id, class_name: 'Organization::EnergyClassification'

    has_many :localpools_as_dso, class_name: 'Group::Localpool', foreign_key: :distribution_system_operator_id
    has_many :localpools_as_tso, class_name: 'Group::Localpool', foreign_key: :transmission_system_operator_id
    has_many :localpools_as_es, class_name: 'Group::Localpool', foreign_key: :electricity_supplier_id

    # make a scope for each possible market function
    MarketFunction.functions.each_key do |function|
      send :scope, "#{function}s", -> {
        where(id: MarketFunction.send(function).select(:organization_id))
      }
    end

    def groups_with_function
      res = {}
      res[:electricity_supplier] = localpools_as_es
      res[:distribution_system_operator] = localpools_as_dso
      res[:transmission_system_operator] = localpools_as_tso
      res
    end

    def in_market_function(function)
      market_functions.find_by(function: function)
    end

    # Define some class-accessors for commonly used organizations (example: Organization.buzzn).
    # Note they are nil by default, need to be assigned from init code somewhere.
    PREDEFINED_ORGANIZATIONS = %i(buzzn germany)
    mattr_accessor(*PREDEFINED_ORGANIZATIONS)
    PREDEFINED_ORGANIZATIONS.each do |accessor|

      # Defines a predicate method, example: @organization.buzzn?
      define_method "#{accessor}?" do
        self.slug == accessor.to_s
      end

    end

    class << self

      PREDEFINED_ORGANIZATIONS.each do |accessor|
        define_method accessor.to_s do
          self.where(:slug => 'buzzn').first
        end
      end

    end

  end
end
