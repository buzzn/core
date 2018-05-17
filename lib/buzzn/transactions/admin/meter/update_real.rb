require_relative '../meter'
require_relative '../../../operations/discovergy'

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
