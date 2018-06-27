module Schemas
  module Transactions

    Id = Schemas::Support.Form do
      required(:id).filled(:int?)
    end

  end
end
