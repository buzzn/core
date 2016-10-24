Fabricator :contracting_party do
  legal_entity  'natural_person'
  #address       { Fabricate(:address) }
  bank_account  { Fabricate(:bank_account) }
end

Fabricator :company_contracting_party, from: :contracting_party do
  legal_entity  'company'
end
