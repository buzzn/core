require_relative '../contract'

module Schemas::Transactions::Admin::Contract

  Document = Schemas::Support.Form do
    required(:template).filled(:str?)
  end

end
