class UsersController < InheritedResources::Base
  before_filter :authenticate_user!


  def redirect_to_current_user
    @user = current_user
    redirect_to @user
  end
end
