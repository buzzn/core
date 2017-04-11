class BankAccountResource < Buzzn::EntityResource

  model BankAccount

  attributes  :holder,
              :bank_name,
              :bic,
              :iban,
              :direct_debit

  # TODO make bank_name and bic derived from iban and not store them in DB
end
