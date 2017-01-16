class BankAccountResource < JSONAPI::Resource

  attributes  :holder,
              :bank_name,
              :bic,
              :iban,
              :direct_debit

end
