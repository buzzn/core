require_relative '../register'

Schemas::Constraints::Register::MetaOption = Schemas::Support.Form do
  required(:share_with_group).filled(:bool?)
  required(:share_publicly).filled(:bool?)
end
