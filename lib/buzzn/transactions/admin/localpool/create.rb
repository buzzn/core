require_relative '../localpool'
require_relative '../../../schemas/transactions/admin/localpool/create'

class Transactions::Admin::Localpool::Create < Transactions::Base
  def self.for(localpools)
    super(Schemas::Transactions::Admin::Localpool::Create, localpools, :authorize, :persist)
  end

  step :validate, with: :'operations.validation'
  step :authorize, with: :'operations.authorization.create'
  step :persist

  def persist(input, localpools)
    Right(localpools.instance_class.create(localpools.current_user, input))
  end
end
