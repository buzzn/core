require_relative '../meter'
require_relative '../../../schemas/transactions/admin/meter/update_real'

class Transactions::Admin::Meter::UpdateReal < Transactions::Base
  def self.for(meter)
    super(Schemas::Transactions::Admin::Meter::UpdateReal, meter, :authorize, :persist)
  end

  step :validate, with: :'operations.validation'
  step :authorize, with: :'operations.authorization.update'
  step :persist, with: :'operations.action.update'
end
