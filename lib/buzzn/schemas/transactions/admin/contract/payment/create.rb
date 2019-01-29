require_relative '../payment'

Schemas::Transactions::Admin::Contract::Payment::Create = Schemas::Support.Form(Schemas::Constraints::Contract::Payment)
