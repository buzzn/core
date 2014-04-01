class GroupsController < InheritedResources::Base
  before_filter :authenticate_user!
  respond_to :html


  def show
    @group = Group.friendly.find(params[:id])
    show!
  end

  def edit
    @group = Group.friendly.find(params[:id])
    edit!
  end

  def update
    @group = Group.friendly.find(params[:id])
    update!
  end


  def permitted_params
    params.permit(:group => [:name, :mode, :public])
  end

end
