Fabricator :contracting_party do
  legal_entity  'me'
  address       { Fabricate(:address) }
  bank_account  { Fabricate(:bank_account) }
end