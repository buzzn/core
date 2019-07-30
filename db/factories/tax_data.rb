FactoryGirl.define do
  factory :tax_data, class: 'Contract::TaxData' do
    # contract
    # retailer
    # provider_permission
    tax_rate 19
    # subject_to_tax
    # tax_number
    # sales_tax_number
    # creditor_identification
  end
end
