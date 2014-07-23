class FriendshipsController < InheritedResources::Base
  before_filter :authenticate_user!
  respond_to :html, :js

  def cancel
    @user = User.find(params[:id])
    @user.friends.delete(current_user)
  end

end