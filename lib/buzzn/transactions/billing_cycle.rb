require_relative 'resource'
Buzzn::Transaction.define do |t|
  t.register_validation(:create_billing_cycle_schema) do
    required(:name).filled(:str?, max_size?: 64)
    required(:begin_date).filled(:date?)
    required(:end_date).filled(:date?)
  end

  t.register_validation(:update_billing_cycle_schema) do
    required(:updated_at).filled(:date_time?)
    optional(:name).filled(:str?, max_size?: 64)
    optional(:begin_date).filled(:date?)
    optional(:end_date).filled(:date?)
  end

  t.define(:create_billing_cycle) do
    validate :create_billing_cycle_schema
    step :resource, with: :nested_resource
  end

  t.define(:update_billing_cycle) do
    validate :update_billing_cycle_schema
    step :resource, with: :update_resource
  end
end
