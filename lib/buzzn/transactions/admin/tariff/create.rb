require_relative '../tariff'
require_relative '../../../schemas/transactions/admin/tariff/create'

class Transactions::Admin::Tariff::Create < Transactions::Base
  def self.for(localpool)
    new.with_step_args(
      validate: [Schemas::Transactions::Admin::Tariff::Create],
      authorize: [localpool, *localpool.permissions.tariffs.create],
      persist: [localpool.tariffs]
    )
  end

  step :validate, with: :'operations.validation'
  step :authorize, with: :'operations.authorization.generic'
  step :persist

  def persist(input, tariffs)
    Right(Admin::TariffResource.new(tariffs.objects.create!(input), tariffs.context))
  end
end
