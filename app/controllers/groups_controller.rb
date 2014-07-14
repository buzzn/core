class GroupsController < InheritedResources::Base
  before_filter :authenticate_user!
  respond_to :html


  def show
    @group      = Group.find(params[:id]).decorate
    @out_users  = @group
  end

  def permitted_params
    params.permit(:group => [:name, :mode, :public])
  end

end
