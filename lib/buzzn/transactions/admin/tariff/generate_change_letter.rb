require_relative '../tariff'
require_relative '../../../schemas/transactions/admin/tariff/generate_change_letter.rb'

class Transactions::Admin::Tariff::GenerateChangeLetter < Transactions::Base

  validate :schema
  authorize :allowed_roles
  map :create_tariff, with: :'operations.action.create_item'

  def schema
    Schemas::Transactions::Admin::Tariff::GenerateChangeLetter
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
