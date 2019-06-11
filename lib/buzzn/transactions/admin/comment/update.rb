require_relative '../comment'

module Transactions::Admin::Comment
  class Update < Transactions::Base

    validate :schema
    authorize :allowed_roles
    map :update_comment, with: :'operations.action.update'

    def schema
      Schemas::Transactions::Admin::Comment::Update
    end

    def allowed_roles(permission_context:)
      permission_context.update
    end

  end
end
