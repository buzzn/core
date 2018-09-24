require_relative '../filterable'
require_relative 'base'

module Organization
  class General < Base

    include Filterable

    belongs_to :contact, class_name: 'Person'
    belongs_to :legal_representation, class_name: 'Person'
    belongs_to :customer_number, foreign_key: :customer_number

    has_many :bank_accounts, foreign_key: :owner_organization_id
    has_many :contracts, class_name: 'Contract::Base', foreign_key: 'customer_organization_id'

    def self.reset_cache
      instance_variables.select { |n| n =~ /@a_/ }.each { |n| instance_variable_set(n, nil) }
    end

    def self.search_attributes
      [:name, :email, :website, :description, address: [:city, :zip, :street]]
    end

    def self.filter(value)
      do_filter(value, *search_attributes)
    end

  end
end
