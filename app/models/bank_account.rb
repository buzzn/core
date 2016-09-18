class BankAccount < ActiveRecord::Base
  include Authority::Abilities
  include Filterable
  include GuardedCrud

  belongs_to :bank_accountable, polymorphic: true


  validates_with IbanValidator

  attr_encrypted :iban, :charset => 'UTF-8', :key => Rails.application.secrets.attr_encrypted_key

  validates :holder,        presence: true
  validates :iban,          presence: true

  def self.readable_by_query(user)
    contracting_party = ContractingParty.arel_table
    contract          = Contract.arel_table
    bank_account      = BankAccount.arel_table
    sqls = [
      contracting_party.where(ContractingParty.readable_by_query(user)
                               .and(contracting_party[:id].eq(bank_account[:bank_accountable_id]))),
      contract.where(Contract.readable_by_query(user)
                      .and(contract[:id].eq(bank_account[:bank_accountable_id])))
    ]
    sqls = sqls.collect{|s| s.project(1).exists}
    sqls[0].or(sqls[1])
  end

  scope :readable_by, -> (user) do
    where(readable_by_query(user))
  end

  def self.search_attributes
    [:holder, :bank_name, :bic]
  end

  def self.filter(search)
    do_filter(search, *search_attributes)
  end

end
