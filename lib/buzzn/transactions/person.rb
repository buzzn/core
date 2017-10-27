require_relative 'resource'
require_relative '../schemas/transactions/person/update'
Buzzn::Transaction.define do |t|
  t.define(:update_person) do
    validate Schemas::Transactions::Person::Update
    step :resource, with: :update_resource
  end
end
