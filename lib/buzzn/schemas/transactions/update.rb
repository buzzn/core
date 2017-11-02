module Schemas
  module Transactions
    Update = Buzzn::Schemas.Form do
      required(:updated_at).filled(:date_time?)
    end
  end
end
