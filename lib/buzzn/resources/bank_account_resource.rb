class BankAccountResource < Buzzn::Resource::Entity

  module Create

  end

  model BankAccount

  attributes  :holder,
              :bank_name,
              :bic,
              :iban,
              :direct_debit,
              :updatable, :deletable

  # TODO make bank_name and bic derived from iban and not store them in DB
end
