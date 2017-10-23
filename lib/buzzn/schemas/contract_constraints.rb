require_relative 'support/form'
ContractConstraints = Buzzn::Schemas.Form do
  required(:signing_date).filled(:date?)
  optional(:begin_date).maybe(:date?)
  optional(:termination_date).maybe(:date?)
  optional(:end_date).maybe(:date?)
end
