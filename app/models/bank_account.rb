class BankAccount < ActiveRecord::Base
  belongs_to :bank_accountable, polymorphic: true

  validates :holder,        presence: true, length: { in: 4..30 }
  validates :iban,          presence: true, length: { in: 4..30 }
  validates :bic,           presence: true, length: { in: 4..30 }
  validates :direct_debit,  presence: true


end
