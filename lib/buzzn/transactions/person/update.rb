require_relative '../person'
require_relative '../../schemas/transactions/person/update'

class Transactions::Person::Update < Transactions::Base
  def self.for(person)
    super(Schemas::Transactions::Person::Update, person, :authorize, :persist)
  end

  step :validate, with: :'operations.validation'
  step :authorize, with: :'operations.authorization.update'
  step :persist, with: :'operations.action.update'
end
