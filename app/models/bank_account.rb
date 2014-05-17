class BankAccount < ActiveRecord::Base
  belongs_to :bank_accountable, polymorphic: true

  validates :holder,        presence: true
  validates :iban,          presence: true
  validates :bic,           presence: true
  validates :direct_debit,  presence: true


end
