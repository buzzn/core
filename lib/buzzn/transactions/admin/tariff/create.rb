require_relative '../tariff'
require_relative '../../../schemas/transactions/admin/tariff/create'

class Transactions::Admin::Tariff::Create < Transactions::Base

  def self.for(localpool)
    new.with_step_args(
      authorize: [localpool, *localpool.permissions.tariffs.create],
      persist: [localpool.tariffs]
    )
  end

  validate :schema
  step :authorize, with: :'operations.authorization.generic'
  map :persist

  def schema
    Schemas::Transactions::Admin::Tariff::Create
  end

  def persist(input, tariffs)
    Contract::TariffResource.new(tariffs.objects.create!(input), tariffs.context)
  end

end
