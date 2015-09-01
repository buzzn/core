class MeteringPointUserRequestsController < InheritedResources::Base
  before_filter :authenticate_user!
  respond_to :html, :js

  def show
    @metering_point_user_request = MeteringPointUserRequest.find(params[:id]).decorate
  end

  def create
    metering_point = MeteringPoint.find(params[:metering_point_id])
    mode = params[:mode]
    @metering_point_user_request = MeteringPointUserRequest.new(user: current_user, metering_point: metering_point, mode: mode)
    if @metering_point_user_request.save
      flash[:notice] = t('sent_metering_point_user_request')
      redirect_to metering_point_path(metering_point)
    else
      flash[:error] = t('unable_to_send_metering_point_user_request')
      redirect_to metering_point_path(metering_point)
    end
  end

  def accept
    @metering_point_user_request = MeteringPointUserRequest.find(params[:id])
    if @metering_point_user_request.mode == 'request' && current_user.can_update?(@metering_point_user_request.metering_point) || @metering_point_user_request.mode == 'invitation' #&& current_user.can_update?(@metering_point_user_request.metering_point)
      @metering_point_user_request.accept
      if @metering_point_user_request.save
        flash[:notice] = t('accepted_metering_point_user_request')
        redirect_to metering_point_path(@metering_point_user_request.metering_point)
      end
    else
      flash[:error] = t('unable_to_accept_metering_point_user_request')
      redirect_to metering_point_path(@metering_point_user_request.metering_point)
    end
  end

  def reject
    @metering_point_user_request = MeteringPointUserRequest.find(params[:id])
    if @metering_point_user_request.mode == 'request' && current_user.can_update?(@metering_point_user_request.metering_point) || @metering_point_user_request.mode == 'invitation' #&& current_user.can_update?(@metering_point_user_request.metering_point)
      @metering_point_user_request.reject
      if @metering_point_user_request.save
        flash[:notice] = t('rejected_metering_point_user_request')
        redirect_to metering_point_path(@metering_point_user_request.metering_point)
      end
    else
      flash[:error] = t('unable_to_reject_metering_point_user_request')
      redirect_to metering_point_path(@metering_point_user_request.metering_point)
    end
  end


end