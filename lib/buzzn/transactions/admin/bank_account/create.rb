require_relative '../bank_account'
require_relative '../../../schemas/transactions/bank_account/create'

class Transactions::Admin::BankAccount::Create < Transactions::Base

  validate :schema
  authorize :allowed_roles
  map :create_bank_account, with: :'operations.action.create_item'

  def schema
    Schemas::Transactions::BankAccount::Create
  end

  def allowed_roles(permission_context:)
    permission_context.bank_accounts.create
  end

  def create_bank_account(params:, resource:)
    BankAccountResource.new(
      *super(resource.bank_accounts, params)
    )
  end

end
