require_relative '../comment'

module Transactions::Admin::Comment
  class Create < Transactions::Base

    validate :schema
    authorize :allowed_roles
    map :create_comment, with: :'operations.action.create_item'

    def schema
      Schemas::Transactions::Admin::Comment::Create
    end

    def allowed_roles(permission_context:)
      permission_context.create
    end

    def create_comment(params:, resource:)
      Admin::CommentResource.new(
        *super(resource, params)
      )
    end

  end
end
