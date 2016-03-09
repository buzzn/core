class FriendshipsController < InheritedResources::Base
  before_filter :authenticate_user!
  respond_to :html, :js

  def cancel
    @user = User.find(params[:id])
    @user.friends.delete(current_user)
    current_user.friends.delete(@user)
    current_user.create_activity(key: 'friendship.cancel', owner: current_user, recipient: @user)
    flash[:notice] = t('cancelled_friendship')
    redirect_to current_user.profile
  end

end