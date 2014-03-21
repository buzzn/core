class FriendshipsController < InheritedResources::Base


  def create
    friend = User.friendly.find(params[:friend_id])
    @friendship = current_user.friendships.build(friend_id: friend.id, status: 'pending')
    if @friendship.save
      flash[:notice] = "Added friend."
      redirect_to root_url
    else
      flash[:error] = "Unable to add friend."
      redirect_to root_url
    end
  end

  def destroy
    @friendship = current_user.friendships.find(params[:id])
    @friendship.destroy
    flash[:notice] = "Removed friendship."
    redirect_to current_user
  end


end
