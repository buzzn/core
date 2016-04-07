class MeteringPointUserRequestsController < InheritedResources::Base
  before_filter :authenticate_user!
  respond_to :html, :js

  def show
    @metering_point_user_request = MeteringPointUserRequest.find(params[:id]).decorate
  end

  def create
    metering_point = MeteringPoint.find(params[:metering_point_id])
    mode = 'request'
    if current_user.can_update?(metering_point)
      current_user.add_role(:member, metering_point)
      metering_point.create_activity key: 'metering_point_user_membership.create', owner: current_user
      flash[:notice] = t('you_were_added_successfully')
    else
      @metering_point_user_request = MeteringPointUserRequest.new(user: current_user, metering_point: metering_point, mode: mode)
      if @metering_point_user_request.save
        metering_point.create_activity(key: 'metering_point_user_request.create', owner: current_user)
        flash[:notice] = t('sent_metering_point_user_request')
      else
        flash[:error] = t('unable_to_send_metering_point_user_request')
      end
    end
    redirect_to metering_point_path(metering_point)
  end

  def accept
    #byebug
    @metering_point_user_request = MeteringPointUserRequest.find(params[:id])
    @metering_point = @metering_point_user_request.metering_point
    @mode = @metering_point_user_request.mode
    @user = @metering_point_user_request.user
    if @mode == 'request' && current_user.can_update?(@metering_point) || @mode == 'invitation'
      @metering_point_user_request.accept
      if @metering_point_user_request.save
        @metering_point.create_activity key: 'metering_point_user_membership.create', owner: @user
        flash[:notice] = t('accepted_metering_point_user_request')
        redirect_to metering_point_path(@metering_point)
      end
    else
      flash[:error] = t('unable_to_accept_metering_point_user_request')
      redirect_to metering_point_path(@metering_point)
    end
  end

  def reject
    @metering_point_user_request = MeteringPointUserRequest.find(params[:id])
    if @metering_point_user_request.mode == 'request' && current_user.can_update?(@metering_point_user_request.metering_point) || @metering_point_user_request.mode == 'invitation'
      @metering_point_user_request.reject
      if @metering_point_user_request.save
        flash[:notice] = t('rejected_metering_point_user_request')
        if @metering_point_user_request.mode == 'invitation'
          @metering_point_user_request.metering_point.create_activity(key: 'metering_point_user_invitation.reject', owner: current_user)
          redirect_to profile_path(@metering_point_user_request.user.profile)
        else
          @metering_point_user_request.metering_point.create_activity(key: 'metering_point_user_request.reject', owner: current_user, recipient: @metering_point_user_request.user)
          redirect_to metering_point_path(@metering_point_user_request.metering_point)
        end
      end
    else
      flash[:error] = t('unable_to_reject_metering_point_user_request')
      redirect_to metering_point_path(@metering_point_user_request.metering_point)
    end
  end


end