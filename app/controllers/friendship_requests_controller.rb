class FriendshipRequestsController < InheritedResources::Base
  before_filter :authenticate_user!
  respond_to :html, :js

  def show
    @friendship_request = FriendshipRequest.find(params[:id]).decorate
  end

  def create
    receiver = User.find(params[:receiver_id])
    @friendship_request = FriendshipRequest.new(sender: current_user, receiver: receiver)
    if @friendship_request.save
      flash[:notice] = t('send_friendship_request')
      redirect_to profile_path(receiver.profile)
    else
      flash[:error] = t('unable_to_send_friendship_request')
      redirect_to profile_path(receiver.profile)
    end
  end

  def accept
    @friendship_request = FriendshipRequest.find(params[:id])
    if @friendship_request.receiver == current_user
      @friendship_request.accept
      if @friendship_request.save
        flash[:notice] = t('accepted_friendship_request')
        redirect_to profile_path(current_user.profile)
      end
    else
      flash[:error] = t('unable_to_accepted_friendship_request')
      redirect_to profile_path(@friendship_request.receiver)
    end
  end

  def reject
    @friendship_request = FriendshipRequest.find(params[:id])
    if @friendship_request.receiver == current_user
      @friendship_request.reject
      if @friendship_request.save
        flash[:notice] = t('rejected_friendship_request')
        redirect_to profile_path(current_user.profile)
      end
    else
      flash[:error] = t('unable_to_accepted_friendship_request')
      redirect_to profile_path(@friendship_request.receiver)
    end
  end


end
