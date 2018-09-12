module Schemas
  module Transactions

    Assign = Schemas::Support.Form do
      required(:id).value(:int?)
    end

  end
end
