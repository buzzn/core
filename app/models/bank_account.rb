require 'buzzn/guarded_crud'
class BankAccount < ActiveRecord::Base
  include Authority::Abilities
  include Filterable
  include Buzzn::GuardedCrud

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

  def self.readable_by_query(user)
    contract     = Contract::Base.arel_table
    bank_account = BankAccount.arel_table
    organization = Organization.arel_table
    user_table   = User.arel_table

    # workaround to produce false always
    return bank_account[:id].eq(bank_account[:id]).not if user.nil?

    # assume all IDs are globally unique
    sqls = [
      User.roles_query(user, admin: nil),
      User.roles_query(user, manager: Organization.where(organization[:id].eq(bank_account[:contracting_party_id]))),
      user_table.where(user_table[:id].eq(user.id)
                      .and(user_table[:id].eq(bank_account[:contracting_party_id])))
    ]
    sqls = sqls.collect{|s| s.project(1).exists}
    sqls[0].or(sqls[1]).or(sqls[2])
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
