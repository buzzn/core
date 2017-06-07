require_relative 'resource'
Buzzn::Transaction.define do |t|
  t.register_validation(:create_regular_billings_schema) do
    required(:accounting_year).filled(:int?)
  end

  t.register_validation(:update_billing_schema) do
    optional(:receivables_cents).filled(:int?)
    optional(:invoice_number).filled(:str?)
    optional(:status).value(included_in?: Billing.all_stati)
  end

  t.define(:create_regular_billings) do
    validate :create_regular_billings_schema
    step :resource, with: :nested_resource
  end

  t.define(:update_billing) do
    validate :update_billing_schema
    step :resource, with: :update_resource
  end
end
