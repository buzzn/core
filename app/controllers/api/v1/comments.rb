module API
  module V1
    class Comments < Grape::API
      include API::V1::Defaults

      resource :comments do

        desc 'Add a comment'
        params do
          requires :resource_id,    type: String, desc: 'Commentable resource id'
          requires :resource_name,  type: String, desc: 'Commentable class name', values: ['Register', 'Group']
          requires :body,           type: String, desc: 'Comment body'
          optional :parent_id,      type: String, desc: 'Parent comment id'
        end
        oauth2 :simple, :full
        post do
          resource_class  = Object.const_get(permitted_params[:resource_name])
          resource        = resource_class.guarded_retrieve(current_user,
                                                            permitted_params[:resource_id])
          if resource.readable_by?(current_user)
            # TODO cleanup move logic into Comment
            comment       = Comment.build_from(resource, current_user.id, permitted_params[:body], nil)
            comment.save!
            comment.create_activity key: 'comment.create', owner: current_user
            if permitted_params[:parent_id]
              parent_comment = Comment.unguarded_retrieve(permitted_params[:parent_id])
              comment.move_to_child_of(parent_comment)
            end
            created_response(comment)
          else
            status 403
          end
        end

        desc 'Update a comment'
        params do
          requires :id,             type: String, desc: 'Comment ID'
          requires :body,           type: String, desc: 'Comment body'
        end
        oauth2 :simple, :full
        patch ':id' do
          comment = Comment.guarded_retrieve(current_user, permitted_params)
          comment.guarded_update(current_user, permitted_params)
        end

        desc 'Remove a comment'
        params do
          requires :id, type: String, desc: 'Comment ID'
        end
        oauth2 :simple, :full
        delete ':id' do
          comment = Comment.guarded_retrieve(current_user, permitted_params)
          deleted_response(comment.guarded_delete(current_user))
        end

      end
    end
  end
end
