require_relative '../../constraints/bank_account'
require_relative '../bank_account'

Schemas::Transactions::BankAccount::Create = Schemas::Constraints::BankAccount
