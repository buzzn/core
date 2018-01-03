class ContractingParty < ActiveRecord::Base
  self.abstract_class = true

  has_many :owned_contracts, class_name: 'Contract::Base', foreign_key: 'contractor_id'
  has_many :assigned_contracts, class_name: 'Contract::Base', foreign_key: 'customer_id'

  has_many :bank_accounts, dependent: :destroy

  def contracts
    Contract::Base.where("contractor_id = ? OR customer_id = ?", self.id, self.id)
  end
end
