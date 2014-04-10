class UsersController < InheritedResources::Base
  before_filter :authenticate_user!


  def show
    @user      = User.find(params[:id])
    @locations = Location.with_role(:manager, @user).decorate
    show!
  end

  def redirect_to_current_user
    @user = current_user
    redirect_to @user
  end

end
