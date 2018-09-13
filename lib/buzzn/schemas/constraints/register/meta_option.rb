require_relative '../register'

Schemas::Constraints::Register::MetaOption = Schemas::Support.Form do
  optional(:share_with_group).maybe(:bool?)
  optional(:share_publicly).maybe(:bool?)
end
