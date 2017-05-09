require_relative 'resource'
Buzzn::Transaction.define do |t|
  t.register_validation(:create_price_schema) do
    required(:name).filled(:str?)
    required(:begin_date).filled(:date?)
    required(:energyprice_cents_per_kilowatt_hour).filled(:float?)
    required(:baseprice_cents_per_month).filled(:int?)
  end

  t.define(:create_price) do
    validate :create_price_schema
    step :resource, with: :create_nested_resource
  end
end
