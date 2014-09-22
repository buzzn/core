class GroupsController < InheritedResources::Base
  respond_to :html, :js

  def show
    @group                          = Group.find(params[:id]).decorate
    @metering_points                = MeteringPoint.by_group_id_and_modes(@group.id, ['out','in']).flatten.uniq
    @energy_producers               = MeteringPoint.by_group_id_and_modes(@group.id, ['out']).decorate.collect(&:users).flatten
    @energy_consumers               = MeteringPoint.by_group_id_and_modes(@group.id, ['in']).decorate.collect(&:users).flatten
    @interested_members             = @group.users

    @group_metering_point_requests  = @group.received_group_metering_point_requests
    @registers                      = @group.metering_points.collect(&:registers)

    @all_users                      = User.all.decorate
    @all_groups                     = Group.all.decorate

    # TODO change to AJAX
    @register_charts = []
    @registers.each do |register|
      @register_charts << register.first.day_to_hours
    end
    gon.push({ register_charts: @register_charts })
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
