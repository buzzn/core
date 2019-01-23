
module Schemas::Transactions::Accounting

  Book = Schemas::Support.Form do
    required(:amount).filled(:bigint?)
    optional(:external_reference).maybe(:str?, max_size?: 256)
    optional(:external_settled_at).maybe(:date?)
    optional(:comment).maybe(:str?, max_size?: 256)
  end

end
