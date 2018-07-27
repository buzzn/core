require_relative '../register'
require_relative '../../../schemas/transactions/admin/register/update_real'

class Transactions::Admin::Register::UpdateReal < Transactions::Base

  validate :schema
  check :authorize, with: :'operations.authorization.update'
  map :persist, with: :'operations.action.update'

  def schema
    Schemas::Transactions::Admin::Register::UpdateReal
  end

  def persist(resource:, params:, **)
    # NOTE this is only until the MeLo are handled on UI properly at the right place, i.e. at the meter itself
    metering_point_id = params.delete(:metering_point_id)
    resource.object.meta.update!(params.except(:updated_at))
    if metering_point_id
      melo = Meter::MeteringLocation.find_by_metering_location_id(metering_point_id) || Meter::MeteringLocation.create(metering_location_id: metering_point_id)
      resource.object.meter.update!(metering_location: melo)
    end
    # note: there is actually no data on register which can be updated
    super(resource: resource, params: params.slice(:updated_at))
  end

end
