FactoryGirl.define do
  factory :bank_account do
    holder                  "Hans Holder"
    iban                    { "DE89370400440532013000" } # taken from https://goo.gl/Ga6573
    bic                     { "BYLADEM1001" }
    bank_name               { ['GLS Bank', 'Sparkasse München', 'Berliner Volksbank', 'UniCredit HypoVereinsbank'].sample }
    direct_debit            true

    after(:build) do |account, _transients|
      # assign contracting_party if not present yet
      account.contracting_party = FactoryGirl.create(:person) unless account.contracting_party
      # this works for both Person and Organization
      account.holder = account.contracting_party.name
    end
  end
end
