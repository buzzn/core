class GroupsController < InheritedResources::Base
  respond_to :html


  def show
    @group                = Group.find(params[:id]).decorate
    @metering_points      = @group.metering_points

    @users                = @group.users
    @out_users            = @metering_points.collect(&:users).first

    # @out_metering_points  = MeteringPoint.by_group_id_and_mode_eq(@group.id, :out).decorate
    # @in_metering_points   = MeteringPoint.by_group_id_and_mode_eq(@group.id, :in).decorate

    # @out_users            = @out_metering_points.collect(&:users).first
    # @in_users             = @in_metering_points.collect(&:users).first

    #@out_devices          = Device.all.decorate
    @groups               = Group.all.decorate
  end

  def permitted_params
    params.permit(:group => [:name, :mode, :public])
  end

end
