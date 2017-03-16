require 'buzzn/guarded_crud'
class BankAccount < ActiveRecord::Base
  include Authority::Abilities
  include Filterable
  include Buzzn::GuardedCrud

  belongs_to :bank_accountable, polymorphic: true


  validates_with IbanValidator

  attr_encrypted :iban, :charset => 'UTF-8', :key => Rails.application.secrets.attr_encrypted_key

  validates :bank_name,     length: { in: 2..63 }
  validates :bic,           length: { in: 8..11 } # iso-9362
  validates :holder,        presence: true, length: { in: 2..63 }
  validates :iban,          presence: true

  def self.readable_by_query(user)
    user_table   = User.arel_table
    organization = Organization.arel_table
    contract     = Contract::Base.arel_table
    bank_account = BankAccount.arel_table

    # workaround to produce false always
    return bank_account[:id].eq(bank_account[:id]).not if user.nil?

    # assume all IDs are globally unique
    sqls = [
      contract.where(Contract::Base.readable_by_query(user)
                      .and(contract[:id].eq(bank_account[:bank_accountable_id]))),
      organization.where(organization[:id].eq(bank_account[:bank_accountable_id])),
      User.roles_query(user, admin: nil)
    ]
    sqls = sqls.collect{|s| s.project(1).exists}
    sqls[0].or(sqls[1]).or(sqls[2]).or(bank_account[:bank_accountable_id].eq(user.id))
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
