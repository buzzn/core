class BankAccountResource < Buzzn::Resource::Entity

  model BankAccount

  attributes  :holder,
              :bank_name,
              :bic,
              :iban,
              :direct_debit,
              :updatable, :deletable

end
