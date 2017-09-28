Fabricator :new_bank_account, class_name: "BankAccount" do
  holder                  "Hans Holder"
  # it would probably be better to set the iban and let the model do it's encryption
  encrypted_iban          "DpglXHRXHXGTDILoRbV/oQKEHaAD0G8rCzgrruOmTxA="
  bic                     "GENODEM1GLS"
  bank_name               "GLS Bank"
  direct_debit            true
  contracting_party       { Fabricate(:new_person) }
end
