class GroupMeteringPointRequestsController < InheritedResources::Base
  before_filter :authenticate_user!
  respond_to :html, :js

  def show
    @group_metering_point_request = GroupMeteringPointRequest.find(params[:id]).decorate
  end

  def create
    group = Group.find(params[:group_id])
    metering_point = MeteringPoint.find(params[:metering_point_id])
    mode = params[:mode]
    if current_user.can_update?(group) && current_user.can_update?(metering_point)
      group.metering_points << metering_point
      flash[:notice] = t('metering_point_added_successfully')
      group.create_activity key: 'group_metering_point_membership.create', owner: current_user, recipient: group
      redirect_to group_path(group)
    else
      @group_metering_point_request = GroupMeteringPointRequest.new(user: current_user, metering_point: metering_point, group: group, mode: mode)
      if @group_metering_point_request.save
        if mode == 'request'
          group.managers.first.send_notification('info', t('new_group_metering_point_request'), metering_point.decorate.name_with_users, 0, group_path(group))
          Notifier.send_email_new_group_metering_point_request(group.managers.first, current_user, metering_point, group, 'request').deliver_now
        else
          metering_point.managers.first.send_notification('info', t('new_group_metering_point_invitation'), group.name, 0, profile_path(metering_point.managers.first.profile))
          Notifier.send_email_new_group_metering_point_request(metering_point.managers.first, current_user, metering_point, group, 'invitation').deliver_now
        end
        flash[:notice] = t('sent_group_metering_point_request')
        redirect_to group_path(group)
      else
        flash[:error] = t('unable_to_send_group_metering_point_request')
        redirect_to group_path(group)
      end
    end
  end

  def accept
    @group_metering_point_request = GroupMeteringPointRequest.find(params[:id])
    if @group_metering_point_request.mode == 'request' && current_user.can_update?(@group_metering_point_request.group) || @group_metering_point_request.mode == 'invitation' && current_user.can_update?(@group_metering_point_request.metering_point)
      @group_metering_point_request.accept
      @group_metering_point_request.group.create_activity key: 'group_metering_point_membership.create', owner: @group_metering_point_request.user, recipient: @group_metering_point_request.group
      if @group_metering_point_request.save
        flash[:notice] = t('accepted_group_metering_point_request')
        if @group_metering_point_request.mode == 'request'
          Notifier.send_email_accepted_group_metering_point_request(@group_metering_point_request.metering_point.managers.first, current_user, @group_metering_point_request.metering_point, @group_metering_point_request.group, 'request').deliver_now
        else
          Notifier.send_email_accepted_group_metering_point_request(@group_metering_point_request.group.managers.first, current_user, @group_metering_point_request.metering_point, @group_metering_point_request.group, 'invitation').deliver_now
        end
        @group_metering_point_request.group.members.each{|user| if user != current_user then user.send_notification('info', t('new_group_member'), @group_metering_point_request.metering_point.decorate.name_with_users, 0, group_path(@group_metering_point_request.group)) end}
        redirect_to group_path(@group_metering_point_request.group)
      end
    else
      flash[:error] = t('unable_to_accept_group_metering_point_request')
      redirect_to group_path(@group_metering_point_request.group)
    end
  end

  def reject
    @group_metering_point_request = GroupMeteringPointRequest.find(params[:id])
    if @group_metering_point_request.mode == 'request' && current_user.can_update?(@group_metering_point_request.group) || @group_metering_point_request.mode == 'invitation' && current_user.can_update?(@group_metering_point_request.metering_point)
      @group_metering_point_request.reject
      if @group_metering_point_request.save
        if @group_metering_point_request.mode == 'request'
          Notifier.send_email_rejected_group_metering_point_request(@group_metering_point_request.metering_point.managers.first, current_user, @group_metering_point_request.metering_point, @group_metering_point_request.group, 'request').deliver_now
        else
          Notifier.send_email_rejected_group_metering_point_request(@group_metering_point_request.group.managers.first, current_user, @group_metering_point_request.metering_point, @group_metering_point_request.group, 'invitation').deliver_now
        end
        flash[:notice] = t('rejected_group_metering_point_request')
        redirect_to group_path(@group_metering_point_request.group)
      end
    else
      flash[:error] = t('unable_to_reject_group_metering_point_request')
      redirect_to group_path(@group_metering_point_request.group)
    end
  end


end