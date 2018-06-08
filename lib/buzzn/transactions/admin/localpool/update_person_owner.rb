require_relative 'owner_base'

module Transactions::Admin::Localpool
  class UpdatePersonOwner < OwnerBase

    validate :schema
    authorize :allowed_roles
    around :db_transaction
    tee :create_or_update_address, with: :'operations.action.create_or_update_address'
    map :update_person, with: :'operations.action.update'

    def schema
      Schemas::Transactions::Person::Update
    end

    def allowed_roles(permission_context:)
      permission_context.owner.create
    end

  end
end
