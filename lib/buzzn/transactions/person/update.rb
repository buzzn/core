require_relative '../person'
require_relative '../../schemas/transactions/person/update'

class Transactions::Person::Update < Transactions::Base

  validate :schema
  check :authorization, with: :'operations.authorization.update_ng'
  step :persist, with: :'operations.action.update_ng'

  def schema
    Schemas::Transactions::Person::Update
  end

end
