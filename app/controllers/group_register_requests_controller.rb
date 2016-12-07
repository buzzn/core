class GroupRegisterRequestsController < InheritedResources::Base
  before_filter :authenticate_user!
  respond_to :html, :js

  def show
    @group_register_request = GroupRegisterRequest.find(params[:id]).decorate
  end

  def create
    group = Group.find(params[:group_id])
    register = Register::Base.find(params[:register_id])
    mode = params[:mode]
    if current_user.can_update?(group) && current_user.can_update?(register)
      group.registers << register
      flash[:notice] = t('register_added_successfully')
      group.create_activity key: 'group_register_membership.create', owner: current_user
      redirect_to group_path(group)
    else
      @group_register_request = GroupRegisterRequest.new(user: current_user, register: register, group: group, mode: mode)
      if @group_register_request.save
        if mode == 'request'
          group.create_activity(key: 'group_register_request.create', owner: current_user, recipient: register)
        else
          group.create_activity(key: 'group_register_invitation.create', owner: current_user, recipient: register)
        end
        flash[:notice] = t('sent_group_register_request')
        redirect_to group_path(group)
      else
        flash[:error] = t('unable_to_send_group_register_request')
        redirect_to group_path(group)
      end
    end
  end

  def accept
    @group_register_request = GroupRegisterRequest.find(params[:id])
    if @group_register_request.mode == 'request' && current_user.can_update?(@group_register_request.group) || @group_register_request.mode == 'invitation' && current_user.can_update?(@group_register_request.register)
      @group_register_request.accept
      if @group_register_request.save
        flash[:notice] = t('accepted_group_register_request')
        @group_register_request.group.create_activity(key: 'group_register_membership.create', owner: @group_register_request.mode == 'invitation' ? current_user : @group_register_request.user, recipient: @group_register_request.register)
        redirect_to group_path(@group_register_request.group)
      end
    else
      flash[:error] = t('unable_to_accept_group_register_request')
      redirect_to group_path(@group_register_request.group)
    end
  end

  def reject
    @group_register_request = GroupRegisterRequest.find(params[:id])
    if @group_register_request.mode == 'request' && current_user.can_update?(@group_register_request.group) || @group_register_request.mode == 'invitation' && current_user.can_update?(@group_register_request.register)
      @group_register_request.reject
      if @group_register_request.save
        if @group_register_request.mode == 'request'
          @group_register_request.group.create_activity(key: 'group_register_request.reject', owner: current_user, recipient: @group_register_request.register)
        else
          @group_register_request.group.create_activity(key: 'group_register_invitation.reject', owner: current_user, recipient: @group_register_request.register)
        end
        flash[:notice] = t('rejected_group_register_request')
        redirect_to group_path(@group_register_request.group)
      end
    else
      flash[:error] = t('unable_to_reject_group_register_request')
      redirect_to group_path(@group_register_request.group)
    end
  end


end