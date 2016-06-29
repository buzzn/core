module API
  module V1
    class Comments < Grape::API
      include API::V1::Defaults

      resource :comments do

        before do
          doorkeeper_authorize! :public
        end

        desc 'Add a comment'
        params do
          requires :resource_id,    type: String, desc: 'Commentable resource id'
          requires :resource_name,  type: String, desc: 'Commentable class name', values: ['MeteringPoint', 'Group']
          requires :body,           type: String, desc: 'Comment body'
          optional :parent_id,      type: String, desc: 'Parent comment id'
        end
        post do
          resource_class  = Object.const_get(permitted_params[:resource_name])
          resource        = resource_class.find(permitted_params[:resource_id])
          if resource.readable_by?(current_user)
            comment       = Comment.build_from(resource, current_user.id, permitted_params[:body], nil)
            comment.save
            if permitted_params[:parent_id]
              parent_comment = Comment.find(permitted_params[:parent_id])
              comment.move_to_child_of(parent_comment)
            end
            comment
          else
            status 403
          end
        end

        desc 'Update a comment'
        params do
          requires :id,             type: String, desc: 'Comment ID'
          requires :body,           type: String, desc: 'Comment body'
        end
        put ':id' do
          comment = Comment.find(permitted_params[:id])
          if comment.updatable_by?(current_user)
            comment.update({ body: permitted_params[:body] })
            comment
          else
            status 403
          end
        end

        desc 'Remove a comment'
        params do
          requires :id, type: String, desc: 'Comment ID'
        end
        delete ':id' do
          comment = Comment.find(permitted_params[:id])
          if comment.deletable_by?(current_user)
            comment.destroy
          else
            status 403
          end
        end

      end
    end
  end
end