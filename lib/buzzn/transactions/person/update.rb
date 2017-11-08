require_relative '../person'
require_relative '../../schemas/transactions/person/update'

class Transactions::Person::Update < Transactions::Base
  def self.create(person)
    new.with_step_args(
      validate: [Schemas::Transactions::Person::Update],
      authorize: [person],
      persist: [person]
    )
  end

  step :validate, with: :'operations.validation'
  step :authorize, with: :'operations.authorization.update'
  step :persist, with: :'operations.action.update'
end
