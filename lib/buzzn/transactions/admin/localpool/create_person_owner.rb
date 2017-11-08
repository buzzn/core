require_relative '../localpool'

class Transactions::Admin::Localpool::CreatePersonOwner < Transaction::Base
  def self.for(localpool)
    new.with_step_args(
      validate: [Schemas::Transactions::Admin::Person::Create],
      authorize: [localpool, :assign],
      persist: [localpool]
    )
  end

  step :validate, with: 'operations.validation'
  step :authorize, with: :'operations.authorize.generic'
  step :persist

  def persist(input, localpools)
    Group::Localpool.transaction do
      person = localpool.object.persons.build(input)
      localpool.object.update!(owner: person)
    end
    Right(localpool.owner)
  end
end
