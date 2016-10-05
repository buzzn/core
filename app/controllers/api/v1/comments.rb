module API
  module V1
    class Comments < Grape::API
      include API::V1::Defaults

      resource :comments do

        desc 'Add a comment'
        params do
          requires :resource_id,    type: String, desc: 'Commentable resource id'
          requires :resource_name,  type: String, desc: 'Commentable class name', values: ['MeteringPoint', 'Group']
          requires :body,           type: String, desc: 'Comment body'
          optional :parent_id,      type: String, desc: 'Parent comment id'
        end
        oauth2 :simple, :full
        post do
          resource_class  = Object.const_get(permitted_params[:resource_name])
          # TODO really unguarded ?
          resource        = resource_class.unguarded_retrieve(permitted_params[:resource_id])
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
          if comment.updatable_by?(current_user)
            comment.update!(permitted_params)
            comment
          else
            status 403
          end
        end

        desc 'Remove a comment'
        params do
          requires :id, type: String, desc: 'Comment ID'
        end
        oauth2 :simple, :full
        delete ':id' do
          comment = Comment.guarded_retrieve(current_user, permitted_params)
          if comment.deletable_by?(current_user) && !comment.has_children?
            comment.destroy
            status 204
          else
            status 403
          end
        end

      end
    end
  end
end
