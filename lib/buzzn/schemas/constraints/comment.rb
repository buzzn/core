require_relative '../constraints'

Schemas::Constraints::Comment = Schemas::Support.Form do
  required(:content).filled(:str?, max_size?: 65536)
  required(:author).filled(:str?, max_size?: 192)
end
