module Schemas
  module Transactions

    Update = Schemas::Support.Form do
      required(:updated_at).filled(:date_time?)
    end

    UpdateOptional = Schemas::Support.Form do
      optional(:updated_at).filled(:date_time?)
    end

  end
end
