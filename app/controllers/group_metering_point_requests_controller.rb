class GroupMeteringPointRequestsController < InheritedResources::Base
  before_filter :authenticate_user!
  respond_to :html, :js

  def show
    @group_metering_point_request = GroupMeteringPointRequest.find(params[:id]).decorate
  end

  def create
    group = Group.find(params[:group_id])
    @group_metering_point_request = GroupMeteringPointRequest.new(user: current_user, metering_point: current_user.metering_points.first, group: group)
    if @group_metering_point_request.save
      flash[:notice] = t('sent_group_metering_point_request')
      redirect_to group_path(group)
    else
      flash[:error] = t('unable_to_send_group_metering_point_request')
      redirect_to group_path(group)
    end
  end

  def accept
    @group_metering_point_request = GroupMeteringPointRequest.find(params[:id])
    if current_user.can_update?(@group_metering_point_request.group)
      @group_metering_point_request.accept
      @group_metering_point_request.create_activity key: 'group_metering_point_membership.create', owner: current_user, recipient: @group_metering_point_request.group
      if @group_metering_point_request.save
        flash[:notice] = t('accepted_group_metering_point_request')
        redirect_to group_path(@group_metering_point_request.group)
      end
    else
      flash[:error] = t('unable_to_accepted_friendship_request')
      redirect_to group_path(@group_metering_point_request.group)
    end
  end

  def reject
    @group_metering_point_request = GroupMeteringPointRequest.find(params[:id])
    if current_user.can_update?(@group_metering_point_request.group)
      @group_metering_point_request.reject
      if @group_metering_point_request.save
        flash[:notice] = t('rejected_group_metering_point_request')
        redirect_to group_path(@group_metering_point_request.group)
      end
    else
      flash[:error] = t('unable_to_rejected_group_metering_point_request')
      redirect_to group_path(@group_metering_point_request.group)
    end
  end


end