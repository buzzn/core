require_relative '../schemas/transactions/display/score'

class Buzzn::Transaction

  define do |t|

    t.define(:scores) do
      validate Schemas::Transactions::Display::Score
      step :resource, with: :nested_resource
    end
  end
end
