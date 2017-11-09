require_relative '../bank_account'
require_relative '../../../schemas/transactions/bank_account/update'

class Transactions::Admin::BankAccount::Update < Transactions::Base
  def self.for(bank_account)
    super(Schemas::Transactions::BankAccount::Update, bank_account, :authorize, :persist)
  end

  step :validate, with: :'operations.validation'
  step :authorize, with: :'operations.authorization.update'
  step :persist, with: :'operations.action.update'
end
