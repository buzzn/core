class CommentsController < InheritedResources::Base
  before_filter :authenticate_user!
  respond_to :html, :js

  def create
    @comment_hash = params[:comment]
    @obj = @comment_hash[:commentable_type].constantize.find(@comment_hash[:commentable_id])
    if user_signed_in? #TODO: bring commentable_by? to work
      @comment = Comment.build_from(@obj, current_user.id, @comment_hash[:body])
      create! do |success, failure|
        success.js { @comment }
        failure.js { render nothing: true, status: :ok } #TODO: show validation errors
      end
    # else
    #   format.js { "alert('no permission');" }

    end

  end


  def destroy
    @comment = Comment.find(params[:id])
    if current_user == @comment.user || current_user.can_update?(@group)
      if @comment.destroy
        render :json => @comment, :status => :ok
      else
        render :js => "alert('error deleting comment');"
      end
    end
  end

  def permitted_params
    params.permit(:comment => [:title, :body, :subject, :user_id, :commentable_id, :commentably_type, :parent_id])
  end
end