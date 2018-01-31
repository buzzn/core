require_relative 'localpool'

module Schemas
  module Invariants
    module Contract
      LocalpoolThirdParty = Schemas::Support.Form(Localpool) do
        required(:customer)                { none? }
        required(:contractor)              { none? }
        required(:register)                { filled? }
        required(:customer_bank_account)   { none? }
        required(:contractor_bank_account) { none? }
        # empty? does not work - hard to debug these predicates
        required(:tariffs)                 { size?(0) }
        required(:payments)                { size?(0) }
      end
    end
  end
end
