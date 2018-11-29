require_relative '../contract'

Schemas::Transactions::Admin::Contract::Base = Schemas::Support.Form do
  optional(:signing_date).maybe(:date?)
  optional(:begin_date).maybe(:date?)
  optional(:termination_date).maybe(:date?)
  optional(:last_date).maybe(:date?)
end
