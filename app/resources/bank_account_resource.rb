class BankAccountResource < ApplicationResource

  attributes  :holder,
              :bank_name,
              :bic,
              :iban,
              :direct_debit,
              :mandate

end
