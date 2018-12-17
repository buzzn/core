FactoryGirl.define do
  factory :billing do
    status                       :open
    begin_date                   { Date.new(2017, 1, 1) }
    end_date                     { Date.new(2018, 1, 1) }
    invoice_number               { generate(:billing_invoice_number) }
  end
end
