require_relative 'filterable'
require_relative 'concerns/person_organization_relation'

class BankAccount < ActiveRecord::Base

  include Filterable

  PersonOrganizationRelation.generate(self, 'owner')

  has_many :contracts, class_name: 'Contract::Base'

  def self.search_attributes
    [:holder, :bank_name]
  end

  def self.filter(search)
    do_filter(search, *search_attributes)
  end

end
