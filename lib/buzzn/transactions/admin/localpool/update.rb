require_relative '../localpool'
require_relative '../../../schemas/transactions/admin/localpool/update'

class Transactions::Admin::Localpool::Update < Transactions::Base
  def self.for(localpool)
    super(Schemas::Transactions::Admin::Localpool::Update, localpool, :authorize, :persist)
  end

  step :validate, with: :'operations.validation'
  step :authorize, with: :'operations.authorization.update'
  step :persist, with: :'operations.action.update'
end
