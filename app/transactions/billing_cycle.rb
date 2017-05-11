require_relative 'resource'
Buzzn::Transaction.define do |t|
  t.register_validation(:create_billing_cycle_schema) do
    required(:name).filled(:str?)
    required(:begin_date).filled(:date?)
    required(:end_date).filled(:date?)
  end

  t.register_validation(:update_billing_cycle_schema) do
    optional(:name).filled(:str?)
    optional(:begin_date).filled(:date?)
    optional(:end_date).filled(:date?)
  end

  t.define(:create_billing_cycle) do
    validate :create_billing_cycle_schema
    step :resource, with: :create_nested_resource
  end

  t.define(:update_billing_cycle) do
    validate :update_billing_cycle_schema
    step :resource, with: :update_resource
  end
end
