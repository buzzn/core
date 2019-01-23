require_relative '../accounting'

Schemas::Constraints::Accounting::Entry = Schemas::Support.Form do
  # deca cents, 1 Euro ^= 1000 dc
  required(:amount).filled(:bigint?)
  required(:checksum).filled(:str?, max_size?: 256)
  optional(:previous_checksum).maybe(:str?, max_size?: 256)
  optional(:external_reference).maybe(:str?, max_size?: 256)
  optional(:external_settled_at).maybe(:date?)
  optional(:comment).maybe(:str?, max_size?: 256)
end
