require_relative '../bank_account'
require_relative '../../../schemas/transactions/bank_account/update'

class Transactions::Admin::BankAccount::Update < Transactions::Base

  validate :schema
  check :authorize, with: :'operations.authorization.update'
  map :persist, with: :'operations.action.update'

  def schema
    Schemas::Transactions::BankAccount::Update
  end

end
