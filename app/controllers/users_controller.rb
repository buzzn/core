class UsersController < InheritedResources::Base
  before_filter :authenticate_user!

  def show
    @user = User.friendly.find(params[:id])
    show!
  end

end
