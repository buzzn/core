require_relative '../../../operations/discovergy'
require_relative '../../../schemas/transactions/admin/meter/update_real'
require_relative '../meter'

class Transactions::Admin::Meter::UpdateReal < Transactions::Base

  validate :schema
  check :authorize, with: :'operations.authorization.update'
  tee :assign, with: :'operations.action.assign'
  check :check_discovergy, with: :'operations.discovergy'
  map :save, with: :'operations.action.save'

  def schema
    Schemas::Transactions::Admin::Meter::UpdateReal
  end

end
