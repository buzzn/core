class BankAccount < ActiveRecord::Base
  include Filterable
  include Owner

  has_many :contracts, class_name: 'Contract::Base'

  # permissions helpers

  scope :permitted, ->(uuids) { where(id: uuids) }

  def self.search_attributes
    [:holder, :bank_name]
  end

  def self.filter(search)
    do_filter(search, *search_attributes)
  end

end
