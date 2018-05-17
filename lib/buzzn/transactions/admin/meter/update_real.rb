require_relative '../meter'
require_relative '../../../operations/check_discovergy'

class Transactions::Admin::Meter::UpdateReal < Transactions::Base

  def self.for(meter)
    super(meter, :authorize, :assign)
  end

  validate :schema
  step :authorize, with: :'operations.authorization.update'
  step :assign, with: :'operations.action.assign'
  step :check_discovergy, with: :'operations.check_discovergy'
  step :save, with: :'operations.action.save'

  def schema
    Schemas::Transactions::Admin::Meter::UpdateReal
  end

end
