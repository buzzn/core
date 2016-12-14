class CommentsController < InheritedResources::Base
  before_filter :authenticate_user!
  respond_to :html, :js, :json

  def create
    @comment_hash = params[:comment]
    @obj = @comment_hash[:commentable_type].constantize.find(@comment_hash[:commentable_id])
    if user_signed_in?
      @comment = Comment.build_from(@obj, current_user.id, @comment_hash[:body], @comment_hash[:parent_id])
      if @comment_hash[:image].present?
        @comment.image = @comment_hash[:image]
      end
      if @comment_hash[:chart_timestamp].present?
        @comment.chart_timestamp = Time.at(@comment_hash[:chart_timestamp].to_i/1000).to_datetime
        @comment.chart_resolution = @comment_hash[:chart_resolution]
      end
      create! do |success, failure|
        success.js {
          #byebug
          html = render_to_string :partial => 'comments/comment', :collection => [@comment], :as => :comment, :formats => [:html]
          @socket_id = params[:socket_id].nil? ? "" : params[:socket_id]

          @comment.create_activity key: 'comment.create', owner: current_user
          if @comment.parent_id.nil?
            @root_id = @comment.commentable_id
            @root_type = @comment.commentable_type
          else
            @root_id = @comment.parent_id
            @root_type = 'Comment'
          end
          @channel_name = @comment.commentable_type.to_s.split(':')[0] + '_' + @comment.commentable_id
          if @comment.commentable_type == "PublicActivity::ORM::ActiveRecord::Activity"
            @channel_name = @comment.commentable.trackable_type + '_' + @comment.commentable.trackable_id
          end
          Pusher.trigger(@channel_name, 'new_comment', :id => @comment.id, :html => html, :root_id => @root_id, :root_type => @root_type, :socket_id => @socket_id)
          render "create", :locals => { :socket_id => @socket_id }
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
    if @comment.user != current_user
      if current_user.liked?(@comment)
        @comment.unliked_by current_user
      else
        @comment.liked_by current_user
        @comment.create_activity(key: 'comment.liked', owner: current_user)
      end
    end
    @channel_name = @comment.commentable_type + '_' + @comment.commentable_id
    @div = 'comment_' + @comment.id
    if @comment.commentable_type == "PublicActivity::ORM::ActiveRecord::Activity"
      @channel_name = @comment.commentable.trackable_type + '_' + @comment.commentable.trackable_id
    end
    Pusher.trigger(@channel_name, 'likes_changed', :div => @div, :likes => @comment.get_likes.size, :voters => @comment.get_likes.voters.collect(&:name).join(", "), :i18n_this_comment => t('this_comment'), :socket_id => @socket_id)
    render :json => { :likes => @comment.get_likes.size, :liked_by_current_user => current_user.liked?(@comment), :voters => @comment.get_likes.voters.collect(&:name).join(", "), :i18n_this_comment => t('this_comment')}
  end


  def permitted_params
    params.permit(:comment => [:title, :body, :subject, :user_id, :commentable_id, :commentably_type, :parent_id, :image])
  end
end