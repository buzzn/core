FactoryGirl.define do
  factory :organization_market_function, class: 'Organization::MarketFunction' do
    function { Organization::MarketFunction.functions.keys.sample }
    # sequences
    market_partner_id { generate(:market_partner_id) }
    edifact_email { generate(:edifact_email) }
    # associations
    contact_person { FactoryGirl.create(:person) }
    address

    before(:create) do |function, _transients|
      function.organization ||= FactoryGirl.create(:organization, :market)
    end
  end
end
