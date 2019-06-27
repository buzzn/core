require_relative '../admin_roda'

module Admin
  class CommentRoda < BaseRoda

    include Import.args[:env,
                        'transactions.admin.comment.create',
                        'transactions.admin.comment.update',
                        'transactions.admin.comment.delete']

    plugin :shared_vars

    route do |r|
      comments = shared[:comments]

      r.get! { comments }
      r.post! { create.(resource: comments, params: r.params) }

      r.on :id do |id|
        comment = comments.retrieve(id)

        r.get! { comment }
        r.patch! { update.(resource: comment, params: r.params) }
        r.delete! { delete.(resource: comment) }
        r.others!

      end

    end

  end
end
