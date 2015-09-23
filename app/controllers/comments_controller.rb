class CommentsController < InheritedResources::Base
  before_filter :authenticate_user!
  respond_to :html, :js, :json

  def create
    @comment_hash = params[:comment]
    @obj = @comment_hash[:commentable_type].constantize.find(@comment_hash[:commentable_id])
    if user_signed_in? #TODO: bring commentable_by? to work
      @comment = Comment.build_from(@obj, current_user.id, @comment_hash[:body])
      create! do |success, failure|
        success.js {
          # if !params[:socket_id].nil?
          #   @socket_id = params[:socket_id]
          # else
          #   @socket_id = ""
          # end
          #@comment.create_activity key: 'comment.create', owner: current_user, recipient_type: @comment_hash[:commentable_type], recipient_id: @comment_hash[:commentable_id]
          #time = ActionController::Base.helpers.timeago_tag(@comment.updated_at, :nojs => true, :lang => locale, :limit => 10.days.ago)
          #Pusher.trigger("#{@comment.commentable_type}_#{@comment.commentable_id}", 'new_comment', :id => @comment.id, :img_alt => I18n.t('profile_picture'), :image => @comment.user.profile.image? ? ActionController::Base.helpers.image_url(@comment.user.profile.image.sm) : @comment.user.profile.decorate.picture('sm') , :user_name => @comment.user.name, :profile_href => profile_path(@comment.user.profile), :body => @comment.body, :created_at => time, :likes => 0, :socket_id => @socket_id)
          @comment
        }
        failure.js {
          render nothing: true, status: :ok
        } #TODO: show validation errors
      end
    end
  end


  def destroy
    @comment = Comment.find(params[:id])
    if current_user == @comment.user || current_user.can_update?(@group)
      if @comment.destroy
        activities = PublicActivity::Activity.where(trackable_id: @comment.id).where(trackable_type: 'Comment')
        activities.each do |activity|
          activity.destroy
        end
        render :json => @comment, :status => :ok
      else
        render :js => "alert('error deleting comment');"
      end
    end
  end

  def increase_likes
    @comment = Comment.find(params[:id])
    @comment.likes.nil? ? @comment.likes = 0 : nil
    @comment.likes += 1
    if @comment.save
      render :json => { :likes => @comment.likes}
    end
  end

  def permitted_params
    params.permit(:comment => [:title, :body, :subject, :user_id, :commentable_id, :commentably_type, :parent_id])
  end
end