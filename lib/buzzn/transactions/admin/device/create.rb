require_relative '../device'
require_relative '../../../schemas/transactions/device/create'

class Transactions::Admin::Device::Create < Transactions::Base

  validate :schema
  authorize :allowed_roles
  tee :convert_kilowatt, with: :'operations.convert_kilowatt'
  map :create, with: :'operations.action.create_item'

  def schema
    Schemas::Transactions::Device::Create
  end

  def allowed_roles(permission_context:)
    permission_context.device.create
  end

  def create(params:, resource:)
    DevicetResource.new(
      *super(resource.devices, params)
    )
  end

  def convert_kilowatt(params: params)
    super(params: params, map: { kw_peak: :watt_peak,
                                 kwh_per_annum: :watt_hour_pa})
  end

end
