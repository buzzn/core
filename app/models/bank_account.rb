class BankAccount < ActiveRecord::Base
  belongs_to :bank_accountable, polymorphic: true
end
