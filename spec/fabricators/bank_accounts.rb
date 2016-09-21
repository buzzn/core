Fabricator :bank_account do
  holder       { FFaker::Name.name }
  iban         'DE23100000001234567890'
  bic          { FFaker::Product.letters(8) }
  bank_name    { FFaker::Company.name.slice(0...63) }
  direct_debit { FFaker::Boolean.maybe }
  mandate      { FFaker::Boolean.maybe }
end
Fabricator :bank_account_mustermann do
  holder      'Max Musterman'
  iban        'DE23100000001234567890'
  bic         'BELADEBE'
  bank_name   'Berliner Sparkasse'
  direct_debit true
  mandate      false
end
