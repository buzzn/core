class BankAccountResource < Buzzn::Resource::Entity

  module Create
    def create_bank_account(holder:, iban:, direct_debit: false)
      BankAccount.create(current_user,
                         holder: holder,
                         iban: iban,
                         direct_debit: direct_debit,
                         contracting_party: object)
    end
  end

  model BankAccount

  attributes  :holder,
              :bank_name,
              :bic,
              :iban,
              :direct_debit

  # TODO make bank_name and bic derived from iban and not store them in DB
end
