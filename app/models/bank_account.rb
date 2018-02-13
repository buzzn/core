require_relative 'filterable'
require_relative 'concerns/person_organization'

class BankAccount < ActiveRecord::Base

  include Filterable

  PersonOrganization.generate(self, 'owner')

  has_many :contracts, class_name: 'Contract::Base'

  # permissions helpers

  scope(:permitted, lambda do |uids|
    ids = uids.collect { |u| u.start_with?('BankAccount') ? u.sub('BankAccount:', '') : nil }
    where(id: ids)
  end)

  def self.search_attributes
    [:holder, :bank_name]
  end

  def self.filter(search)
    do_filter(search, *search_attributes)
  end

end
