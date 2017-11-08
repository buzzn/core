require_relative '../localpool'

class Transactions::Admin::Localpool::CreatePersonOwner < Transaction::Base
  def self.create(localpool)
    new.with_step_args(
      validate: [Schemas::Transactions::Admin::Organization::Create],
      authorize: [localpool, :assign],
      persist: [localpool]
    )
  end

  step :validate, with: 'operations.validation'
  step :authorize, with: :'operations.authorize.generic'
  step :persist

  def persist(input, localpools)
    Group::Localpool.transaction do
      organization = localpool.object.organizations.build(input)
      localpool.object.update!(owner: organization)
    end
    Right(localpool.owner)
  end
end
