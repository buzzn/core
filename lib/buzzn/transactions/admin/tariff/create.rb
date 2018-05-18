require_relative '../tariff'
require_relative '../../../schemas/transactions/admin/tariff/create'

class Transactions::Admin::Tariff::Create < Transactions::Base

  validate :schema
  authorize :allowed_roles
  map :create_tariff, with: :'operations.action.create_item'


  def schema
    Schemas::Transactions::Admin::Tariff::Create
  end

  def allowed_roles(permission_context:)
    permission_context.tariffs.create
  end

  def create_tariff(params:, resource:)
    Contract::TariffResource.new(
      *super(resource.tariffs, params)
    )
  end

end
