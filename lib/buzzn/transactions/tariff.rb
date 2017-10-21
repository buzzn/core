require_relative 'resource'
require_relative '../schemas/tariff_create'
Buzzn::Transaction.define do |t|

  t.define(:create_tariff) do
    validate TariffCreate
    step :resource, with: :nested_resource
  end
end
