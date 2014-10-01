class CommentsController < InheritedResources::Base
  before_filter :load_commentable

  def create
    @comment = @commentable.comments.build(params[:comment])
    @comment.user = current_user
    respond_to do |format|
      if @comment.save
        format.html { redirect_to @commentable }
      else
        format.html { render :action => 'new' }
      end
    end
  end

  protected

  def load_commentable
    @commentable = params[:commentable_type].camelize.constantize.find(params[:commentable_id])
  end

  def permitted_params
    params.permit(:comment => [:title, :body, :subject, :user_id, :commentable_id, :commentably_type, :parent_id])
  end
end