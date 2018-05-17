require_relative '../bank_account'
require_relative '../../../schemas/transactions/bank_account/update'

class Transactions::Admin::BankAccount::Update < Transactions::Base

  validate :schema
  check :authorize, with: :'operations.authorization.update_ng'
  step :persist, with: :'operations.action.update_ng'

  def schema
    Schemas::Transactions::BankAccount::Update
  end

end
