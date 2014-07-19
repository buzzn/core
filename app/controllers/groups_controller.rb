class GroupsController < InheritedResources::Base
  respond_to :html, :js

  def show
    @group                = Group.find(params[:id]).decorate
    @metering_points      = @group.metering_points
    @users                = @group.users
    @out_users            = @metering_points.collect(&:users).first
    @groups               = Group.all.decorate
    gon.push({ metering_points: @group.metering_points.collect(&:day_to_hours) })
  end

  def edit
    edit! do |format|
      @group = GroupDecorator.new(@group)
    end
  end

  def permitted_params
    params.permit(:group => [:name, :mode, :public])
  end

end
