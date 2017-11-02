require_relative '../schemas/transactions/chart'

class Buzzn::Transaction
  define do |t|
    t.define(:charts) do
      validate Schemas::Transactions::Chart
      step :resource, with: :nested_resource
    end
  end
end
