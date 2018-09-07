require_relative 'base'
require_relative '../../../schemas/transactions/device/update'

module Transactions::Admin::Device
  class Update < Base

    validate :schema
    check :authorize, with: :'operations.authorization.update'
    tee :convert_kilowatt, with: :'operations.convert_kilowatt'
    map :persist, with: :'operations.action.update'

    def schema
      Schemas::Transactions::Device::Update
    end

    def convert_kilowatt(params:, resource:)
      super(params: params, map: { kw_peak: :watt_peak,
                                   kwh_per_annum: :watt_hour_pa})
    end

  end
end
