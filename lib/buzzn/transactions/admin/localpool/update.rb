require_relative '../localpool'
require_relative '../../../schemas/transactions/admin/localpool/update'

class Transactions::Admin::Localpool::Update < Transactions::Base

  def self.for(localpool)
    super(localpool, :authorize, :persist)
  end

  validate :schema
  step :authorize, with: :'operations.authorization.update'
  step :persist, with: :'operations.action.update'

  def schema
    Schemas::Transactions::Admin::Localpool::Update
  end

end
