# coding: utf-8
FactoryGirl.define do
  factory :bank_account do
    transient do
      owner nil
    end
    holder                  "Hans Holder"
    iban                    { "DE89370400440532013000" } # taken from https://goo.gl/Ga6573
    bic                     { "BYLADEM1001" }
    bank_name               { ['GLS Bank', 'Sparkasse München', 'Berliner Volksbank', 'UniCredit HypoVereinsbank'].sample }
    direct_debit            true

    after(:build) do |account, transients|
      # assign owner if not present yet
      account.owner = FactoryGirl.create(:person) unless transients.owner
      # this works for both Person and Organization
      account.holder = (account.owner || transients.owner).name
    end
  end
end
