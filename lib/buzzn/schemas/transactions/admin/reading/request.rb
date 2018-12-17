require_relative '../reading'

Schemas::Transactions::Admin::Reading::Request = Schemas::Support.Form do
  required(:date).filled(:date?)
end
