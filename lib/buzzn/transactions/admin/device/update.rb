require_relative '../device'
require_relative '../../../schemas/transactions/device/update'

class Transactions::Admin::Device::Update < Transactions::Base

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
