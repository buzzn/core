require_relative '../contract'

Schemas::Constraints::Contract::Base = Schemas::Support.Form do
  optional(:signing_date).maybe(:date?)
  optional(:begin_date).maybe(:date?)
  optional(:termination_date).maybe(:date?)
  optional(:end_date).maybe(:date?)
end
