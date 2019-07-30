require_relative '../constraints'

Schemas::Constraints::Billing = Schemas::Support.Form do
  required(:status).value(included_in?: Billing.status.values)
  required(:begin_date).filled(:date?)
  required(:end_date).filled(:date?)
  optional(:invoice_number).maybe(:str?, max_size?: 64)
end
