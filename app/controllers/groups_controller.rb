class GroupsController < InheritedResources::Base
  before_filter :authenticate_user!
  respond_to :html


  def permitted_params
    params.permit(:group => [:name, :mode, :public])
  end

end
