class BankAccountResource < Buzzn::Resource::Entity

  module Create
    def create_bank_account(holder:, iban:, bank_name: nil, bic: nil, direct_debit: false)
      create(permissions.create) do
        BankAccount.create(holder: holder,
                           iban: iban,
                           bank_name: bank_name,
                           bic: bic,
                           direct_debit: direct_debit,
                           contracting_party: object)
      end
    end
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
