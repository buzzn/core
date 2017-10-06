FactoryGirl.define do
  factory :bank_account do
    holder                  "Hans Holder"
    iban                    { "DE89370400440532013000" } # taken from https://goo.gl/Ga6573
    bic                     { "BYLADEM1001" }
    bank_name               { ['GLS Bank', 'Sparkasse München', 'Berliner Volksbank', 'UniCredit HypoVereinsbank'].sample }
    direct_debit            true
    contracting_party       { FactoryGirl.create(:person) }

    before(:create) do |account, _transients|
      # this works for both Person and Organization
      account.holder = account.contracting_party.name if account.contracting_party
    end
  end
end