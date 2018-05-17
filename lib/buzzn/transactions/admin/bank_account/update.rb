require_relative '../bank_account'
require_relative '../../../schemas/transactions/bank_account/update'

class Transactions::Admin::BankAccount::Update < Transactions::Base

  def self.for(bank_account)
    super(bank_account, :authorize, :persist)
  end

  validate :schema
  step :authorize, with: :'operations.authorization.update'
  step :persist, with: :'operations.action.update'

  def schema
    Schemas::Transactions::BankAccount::Update
  end

end
