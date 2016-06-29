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
        post do
          doorkeeper_authorize! :admin

          resource_class  = Object.const_get(permitted_params[:resource_name])
          resource        = resource_class.find(permitted_params[:resource_id])
          comment         = Comment.build_from(resource, current_user.id, permitted_params[:body], nil)
          comment.save
          if permitted_params[:parent_id]
            parent_comment = Comment.find(permitted_params[:parent_id])
            comment.move_to_child_of(parent_comment)
          end
          comment
        end

        desc 'Update a comment'
        params do
          requires :id,             type: String, desc: 'Comment ID'
          requires :body,           type: String, desc: 'Comment body'
        end
        put ':id' do
          doorkeeper_authorize! :admin

          comment = Comment.find(permitted_params[:id])
          comment.update({ body: permitted_params[:body] })
          comment
        end

        desc 'Remove a comment'
        params do
          requires :id, type: String, desc: 'Comment ID'
        end
        delete ':id' do
          doorkeeper_authorize! :admin

          Comment.find(permitted_params[:id]).destroy
        end

      end
    end
  end
end