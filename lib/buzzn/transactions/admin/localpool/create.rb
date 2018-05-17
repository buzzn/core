require_relative '../localpool'
require_relative '../../../schemas/transactions/admin/localpool/create'

class Transactions::Admin::Localpool::Create < Transactions::Base

  def self.for(localpools)
    super(localpools, :authorize, :persist)
  end

  validate :schema
  step :authorize, with: :'operations.authorization.create'
  step :persist

  def schema
    Schemas::Transactions::Admin::Localpool::Create
  end

  def persist(input, localpools)
    Success(localpools.instance_class.create(localpools.current_user, input))
  end

end
