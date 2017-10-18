class ContractingParty < ActiveRecord::Base
  self.abstract_class = true

  has_many :owned_contracts, class_name: Contract::Base, foreign_key: 'contractor_id'
  has_many :assigned_contracts, class_name: Contract::Base, foreign_key: 'customer_id'

  has_many :bank_accounts, dependent: :destroy

  validates_associated :address
  validates :sales_tax_number, presence: false
  validates :tax_rate, presence: false
  validates :tax_number, presence: false
  validates :retailer, presence: false
  validates :provider_permission, presence: false
  validates :subject_to_tax, presence: false
  validates :mandate_reference, presence: false

  # TODO ????
  validates :creditor_id, presence: false

  validate :validate_invariants

  def validate_invariants
  end

  def contracts
    Contract::Base.where("contractor_id = ? OR customer_id = ?", self.id, self.id)
  end
end
