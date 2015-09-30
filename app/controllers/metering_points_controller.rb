class MeteringPointsController < ApplicationController
  before_filter :authenticate_user!, except: [:show, :chart, :latest_fake_data, :latest_power]
  respond_to :html, :json, :js

  def show
    @metering_point = MeteringPoint.find(params[:id]).decorate
    @users          = @metering_point.users
    @devices        = @metering_point.devices
    @group          = @metering_point.group
    @meter          = @metering_point.meter
    @requests       = @metering_point.received_user_requests
    if !@metering_point.readable_by_world?
      if user_signed_in?
        authorize_action_for(@metering_point)
      else
        redirect_to root_path
      end
    end
  end


  def new
    @metering_point = MeteringPoint.new(mode: 'in')
    authorize_action_for @metering_point
    2.times{@metering_point.formula_parts.build}
  end


  def create
    @metering_point = MeteringPoint.new(metering_point_params)
    authorize_action_for @metering_point
    if @metering_point.save
      current_user.add_role(:manager, @metering_point)
      @metering_point.create_activity key: 'metering_point.create', owner: current_user
      respond_with @metering_point.decorate
    else
      render :new
    end
  end


  def edit
    @metering_point = MeteringPoint.find(params[:id])
    authorize_action_for(@metering_point)
  end


  def update
    @metering_point = MeteringPoint.find(params[:id])
    authorize_action_for @metering_point
    if @metering_point.update_attributes(metering_point_params)
      respond_with @metering_point
    else
      render :edit
    end
  end

  def destroy
    @metering_point = MeteringPoint.find(params[:id])
    authorize_action_for @metering_point
    @metering_point.destroy
    respond_with current_user.profile
  end



  def edit_users
    # TODO: insert added user directly
    @metering_point = MeteringPoint.find(params[:id]).decorate
    authorize_action_for(@metering_point, action: 'edit_users')
  end
  authority_actions :edit_users => 'update'



  def edit_devices
    # TODO: insert added device directly
    @metering_point = MeteringPoint.find(params[:id]).decorate
    authorize_action_for(@metering_point, action: 'edit_devices')
  end
  authority_actions :edit_devices => 'update'

  def edit_readings
    @metering_point = MeteringPoint.find(params[:id]).decorate
    @readings = @metering_point.submitted_readings_by_user
    authorize_action_for(@metering_point, action: 'edit_devices')
  end
  authority_actions :edit_readings => 'update'

  def cancel_membership
    @metering_point = MeteringPoint.find(params[:id])
    @user = User.find(params[:user_id])
    @metering_point.users.delete(@user)
    redirect_to metering_point_path(@metering_point)
  end

  def send_invitations
    @metering_point = MeteringPoint.find(params[:id])
  end

  def send_invitations_update
    @metering_point = MeteringPoint.find(params[:id])
    if params[:metering_point][:invite_via_email] == "true"
      if params[:metering_point][:email] == "" #|| params[:metering_point][:email_confirmation] == ""
        @metering_point.errors.add(:email, I18n.t("cant_be_blank"))
#        @metering_point.errors.add(:email_confirmation,  I18n.t("cant_be_blank"))
        render action: 'send_invitations', invite_via_email: 'checked'
#      elsif params[:metering_point][:email] != params[:metering_point][:email_confirmation]
#        @metering_point.errors.add(:email, I18n.t("doesnt_match_with_confirmation"))
#        @metering_point.errors.add(:email_confirmation, I18n.t("doesnt_match_with_email"))
#        render action: 'send_invitations', invite_via_email: 'checked'
      else
        @email = params[:metering_point][:email]
        @existing_users = User.where(email: @email)
        if @existing_users.any?
          if MeteringPointUserRequest.where(metering_point: @metering_point).where(user: @existing_users.first).empty? && !@metering_point.users.include?(@existing_users.first)
            if MeteringPointUserRequest.create(user: @existing_users.first, metering_point: @metering_point, mode: 'invitation')
              flash[:notice] = t('sent_metering_point_user_invitation_successfully')
            else
              flash[:error] = t('unable_to_send_metering_point_user_invitation')
            end
          else
            flash[:error] = t('metering_point_user_invitation_already_sent') + '. ' + t('waiting_for_accepting') + '.'
          end
        else
          @new_user = User.invite!({email: @email}, current_user)
          @metering_point.users << @new_user
          current_user.friends << @new_user
          @metering_point.save!
          flash[:notice] = t('invitation_sent_successfully_to', email: @email)
        end
      end
    else
      @new_user = User.find(params[:metering_point][:new_users])
      if MeteringPointUserRequest.create(user: @new_user, metering_point: @metering_point, mode: 'invitation')
        flash[:notice] = t('sent_metering_point_user_invitation_successfully')
      else
        flash[:error] = t('unable_to_send_metering_point_user_invitation')
      end
    end
  end





  def chart
    @metering_point = MeteringPoint.find(params[:id])
    params[:containing_timestamp].nil? ? @containing_timestamp = Time.now.to_i*1000 : @containing_timestamp = params[:containing_timestamp]
    #@cache_id = "/metering_points/#{params[:id]}/chart?resolution=#{params[:resolution]}&containing_timestamp=#{@containing_timestamp}"
    #@cache = Rails.cache.fetch(@cache_id)
    #@data = @cache || @metering_point.chart_data(params[:resolution], @containing_timestamp)
    @data = @metering_point.chart_data(params[:resolution], @containing_timestamp)
    @chart_data = []
    @chart_data << {
      step: 'left',
      type: 'area',
      data: @data,
      name: @metering_point.decorate.long_name

    }
    render json: @chart_data.to_json
  end





  def latest_fake_data
    @metering_point = MeteringPoint.find(params[:id])
    @cache_id = "/metering_points/#{params[:id]}/latest_fake_data"
    @cache = Rails.cache.fetch(@cache_id)
    @latest_fake_data = @cache || @metering_point.latest_fake_data
    render json: @latest_fake_data.to_json
  end




  def latest_power
    @metering_point = MeteringPoint.find(params[:id])
    @cache_id = "/metering_points/#{params[:id]}/latest_power"
    @cache = Rails.cache.fetch(@cache_id)
    last_power = @cache || @metering_point.last_power
    if !last_power.nil?
      latest_power = last_power[:power]
      latest_timestamp = last_power[:timestamp]
      online = true
    else
       latest_power = nil
       latest_timestamp = nil
       online = false
    end
    render json: {
      latest_power: latest_power,
      timestamp:    latest_timestamp,
      smart:        @metering_point.smart?,
      online:       online,
      virtual:      @metering_point.virtual
    }.to_json
  end

  def get_scores
    @metering_point = MeteringPoint.find(params[:id])
    resolution_format = params[:resolution]
    containing_timestamp = params[:containing_timestamp]
    if resolution_format.nil?
      resolution_format = "year"
    end
    if containing_timestamp.nil?
      containing_timestamp = Time.now.to_i * 1000
    end

    if resolution_format == 'day'
      sufficiency = @metering_point.scores.sufficiencies.dayly.at(containing_timestamp).first
      fitting = @metering_point.scores.fittings.dayly.at(containing_timestamp).first
    elsif resolution_format == 'month'
      sufficiency = @metering_point.scores.sufficiencies.monthly.at(containing_timestamp).first
      fitting = @metering_point.scores.fittings.monthly.at(containing_timestamp).first
    elsif resolution_format == 'year'
      sufficiency = @metering_point.scores.sufficiencies.yearly.at(containing_timestamp).first
      fitting = @metering_point.scores.fittings.yearly.at(containing_timestamp).first
    end
    sufficiency.nil? ? sufficiency_value = 0 : sufficiency_value = sufficiency.value
    fitting.nil? ? fitting_value = 0 : fitting_value = fitting.value
    render json: { sufficiency: sufficiency_value, fitting: fitting_value }.to_json
  end






private
  def metering_point_params
    params.require(:metering_point).permit(
      :uid,
      :name,
      :image,
      :mode,
      :readable,
      :virtual,
      :forecast_kwh_pa,
      :group_id,
      :user_ids => [],
      :device_ids => [],
      formula_parts_attributes: [:id, :operator, :metering_point_id, :operand_id, :_destroy]
    )
  end




end
