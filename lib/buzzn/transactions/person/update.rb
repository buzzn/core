require_relative '../person'
require_relative '../../schemas/transactions/person/update'

class Transactions::Person::Update < Transactions::Base

  def self.for(person)
    super(person, :authorize, :persist)
  end

  validate :schema
  step :authorize, with: :'operations.authorization.update'
  step :persist, with: :'operations.action.update'

  def schema
    Schemas::Transactions::Person::Update
  end

end
