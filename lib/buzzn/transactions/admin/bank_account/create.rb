require_relative '../bank_account'
require_relative '../../../schemas/transactions/bank_account/create'

class Transactions::Admin::BankAccount::Create < Transactions::Base
  def self.for(parent)
    new.with_step_args(
      validate: [Schemas::Transactions::BankAccount::Create],
      authorize: [parent, *parent.permissions.bank_accounts.create],
      persist: [parent.bank_accounts]
    )
  end

  step :validate, with: :'operations.validation'
  step :authorize, with: :'operations.authorization.generic'
  step :persist

  def persist(input, bank_accounts)
    Right(BankAccountResource.new(bank_accounts.objects.create!(input), bank_accounts.context))
  end
end
