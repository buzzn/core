require_relative 'base'
require_relative '../../../schemas/transactions/device/create'

module Transactions::Admin::Device
  class Create < Base

    validate :schema
    authorize :allowed_roles
    tee :convert_kilowatt, with: :'operations.convert_kilowatt'
    map :create_device, with: :'operations.action.create_item'

    def schema
      Schemas::Transactions::Device::Create
    end

    def allowed_roles(permission_context:)
      permission_context.create
    end

    def convert_kilowatt(params:, resource:)
      super(params: params, map: { kw_peak: :watt_peak,
                                   kwh_per_annum: :watt_hour_pa})
    end

    def create_device(params:, resource:)
      Admin::DeviceResource.new(
        *super(resource, params)
      )
    end

  end
end
