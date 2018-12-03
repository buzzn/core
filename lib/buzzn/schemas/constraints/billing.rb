require_relative '../constraints'

Schemas::Constraints::Billing = Schemas::Support.Form do
  required(:begin_date).filled(:date?)
  required(:end_date).filled(:date?)
  required(:status).value(included_in?: Billing.status.values)
  optional(:invoice_number).maybe(:str?, max_size?: 64)
end
