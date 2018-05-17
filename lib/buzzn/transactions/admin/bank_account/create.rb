require_relative '../bank_account'
require_relative '../../../schemas/transactions/bank_account/create'

class Transactions::Admin::BankAccount::Create < Transactions::Base

  def self.for(parent)
    new.with_step_args(
      authorize: [parent, *parent.permissions.bank_accounts.create],
      persist: [parent.bank_accounts]
    )
  end

  validate :schema
  step :authorize, with: :'operations.authorization.generic'
  step :persist

  def schema
    Schemas::Transactions::BankAccount::Create
  end

  def persist(input, bank_accounts)
    Success(BankAccountResource.new(bank_accounts.objects.create!(input), bank_accounts.context))
  end

end
