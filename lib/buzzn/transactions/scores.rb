require_relative '../schemas/transactions/score'

class Buzzn::Transaction

  define do |t|

    t.define(:scores) do
      validate Schemas::Transactions::Score
      step :resource, with: :nested_resource
    end
  end
end
