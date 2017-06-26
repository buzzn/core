class BankAccount < ActiveRecord::Base
  include Filterable

  has_many :contracts, class_name: 'Contract::Base'
  belongs_to :contracting_party, polymorphic: true

  validates_with IbanValidator

  attr_encrypted :iban, :charset => 'UTF-8', :key => Rails.application.secrets.attr_encrypted_key

  validates :bank_name,               length: { in: 2..63 }
  validates :bic,                     length: { in: 8..11 } # iso-9362
  validates :holder,                  presence: true, length: { in: 2..63 }
  validates :iban,                    presence: true
  validates :contracting_party_id,    presence: true
  validates :contracting_party_type,  presence: true

  # permissions helpers

  scope :restricted, ->(uuids) { where(id: uuids) }

  def self.search_attributes
    [:holder, :bank_name, :bic]
  end

  def self.filter(search)
    do_filter(search, *search_attributes)
  end

end
