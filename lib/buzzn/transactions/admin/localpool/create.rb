require_relative '../localpool'
require_relative '../../../schemas/transactions/admin/localpool/create'

class Transactions::Admin::Localpool::Create < Transactions::Base

  def self.for(localpools)
    super(localpools, :authorize, :persist)
  end

  validate :schema
  step :authorize, with: :'operations.authorization.create'
  map :persist

  def schema
    Schemas::Transactions::Admin::Localpool::Create
  end

  def persist(input, localpools)
    localpools.instance_class.create(localpools.current_user, input)
  end

end
