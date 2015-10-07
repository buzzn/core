class CommentsController < InheritedResources::Base
  before_filter :authenticate_user!
  respond_to :html, :js, :json

  def create
    @comment_hash = params[:comment]
    @obj = @comment_hash[:commentable_type].constantize.find(@comment_hash[:commentable_id])
    if user_signed_in? #TODO: bring commentable_by? to work
      @comment = Comment.build_from(@obj, current_user.id, @comment_hash[:body], @comment_hash[:parent_id])
      if @comment_hash[:image].present?
        @comment.image = @comment_hash[:image]
      end
      create! do |success, failure|
        success.js {
          #byebug
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
    if @comment.deletable_by?(current_user)
      if @comment.destroy
        activities = PublicActivity::Activity.where(trackable_id: @comment.id).where(trackable_type: 'Comment')
        activities.each do |activity|
          activity.destroy
        end
        @comment
      else
        render :js => "alert('error deleting comment');"
      end
    end
  end

  def voted
    @comment = Comment.find(params[:id])
    if params[:mode] == 'good'
      @comment.liked_by current_user
    elsif params[:mode] == 'bad'
      @comment.disliked_by current_user
    end
    render :json => { :likes => @comment.get_likes.size, :dislikes => @comment.get_dislikes.size}
  end

  def permitted_params
    params.permit(:comment => [:title, :body, :subject, :user_id, :commentable_id, :commentably_type, :parent_id, :image])
  end
end