class GroupsController < InheritedResources::Base
  respond_to :html, :js

  def show
    @group                = Group.find(params[:id]).decorate
    @metering_points      = @group.metering_points
    @users                = @group.users
    @out_users            = @metering_points.collect(&:users).first
    @groups               = Group.all.decorate
    @group_metering_point_requests = @group.received_group_metering_point_requests
    gon.push({ metering_points: @group.metering_points.collect(&:registers['day_to_hours']) })
  end

  def edit
    @group = Group.find(params[:id]).decorate
    authorize_action_for(@group)
    edit!
  end

  def create
    create! do |format|
      current_user.add_role :manager, @group
      @group = GroupDecorator.new(@group)
    end
  end

  def cancel_membership
    @group = Group.find(params[:id])
    @group.metering_points.delete(current_user.metering_points.first)
    current_user.metering_points.first.group = nil
    redirect_to group_path(@group)
  end

  def permitted_params
    params.permit(:group => [:image, :name, :mode, :public])
  end

end
