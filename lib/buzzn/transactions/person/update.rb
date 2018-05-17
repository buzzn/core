require_relative '../person'
require_relative '../../schemas/transactions/person/update'

class Transactions::Person::Update < Transactions::Base

  validate :schema
  check :authorization, with: :'operations.authorization.update'
  map :persist, with: :'operations.action.update'

  def schema
    Schemas::Transactions::Person::Update
  end

end
