class MeteringPointsController < ApplicationController
  before_filter :authenticate_user!, except: [:show, :chart, :latest_fake_data, :latest_power, :widget]
  respond_to :html, :json, :js



  def show
    @metering_point                 = MeteringPoint.find(params[:id]).decorate
    @profiles                       = @metering_point.profiles
    @managers                       = @metering_point.managers
    @devices                        = @metering_point.devices
    @group                          = @metering_point.group
    @meter                          = @metering_point.meter
    @requests                       = @metering_point.received_user_requests
    @all_comments                   = @metering_point.root_comments
    @activities                     = @metering_point.activities.metering_point_joins
    @activities_and_comments        = (@all_comments + @activities).sort_by!(&:created_at).reverse!
    Browser.modern_rules.clear
    Browser.modern_rules << -> b { b.firefox? && b.version.to_i >= 41 }
    browser = Browser.new(ua: request.user_agent, accept_language: request.accept_language)

    authorize_action_for(@metering_point)
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
      #@metering_point.create_activity key: 'metering_point.create', owner: current_user
      respond_with @metering_point.decorate
      flash[:notice] = t('metering_point_created_successfully')
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
    flash[:notice] = t('metering_point_deleted_successfully')
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

  def send_invitations
    @metering_point = MeteringPoint.find(params[:id])
  end

  def send_invitations_update
    @metering_point = MeteringPoint.find(params[:id])
    if params[:metering_point][:invite_via_email] == "true"
      if params[:metering_point][:email] == ""
        @metering_point.errors.add(:email, I18n.t("cant_be_blank"))
        render action: 'send_invitations', invite_via_email: 'checked'
      else
        @email = params[:metering_point][:email]
        @existing_users = User.unscoped.where(email: @email)
        if @existing_users.any?
          if MeteringPointUserRequest.where(metering_point: @metering_point).where(user: @existing_users.first).empty? && !@metering_point.users.include?(@existing_users.first)
            @metering_point_user_request = MeteringPointUserRequest.new(user: @existing_users.first, metering_point: @metering_point, mode: 'invitation')
            if @metering_point_user_request.save
              @metering_point.create_activity(key: 'metering_point_user_invitation.create', owner: current_user, recipient: @existing_users.first)
              flash[:notice] = t('sent_metering_point_user_invitation_successfully')
            else
              flash[:error] = t('unable_to_send_metering_point_user_invitation')
            end
          else
            flash[:error] = t('metering_point_user_invitation_already_sent') + '. ' + t('waiting_for_accepting') + '.'
          end
        else
          @new_user = User.unscoped.invite!({email: @email, invitation_message: params[:metering_point][:message]}, current_user)
          current_user.create_activity key: 'user.create_platform_invitation', owner: current_user, recipient: @new_user
          @new_user.add_role(:member, @metering_point)
          current_user.friends.include?(@new_user) ? nil : current_user.friends << @new_user
          @metering_point.save!
          flash[:notice] = t('invitation_sent_successfully_to', email: @email)
        end
      end
    else
      @new_user = User.find(params[:metering_point][:new_users])
      if MeteringPointUserRequest.where(metering_point: @metering_point).where(user: @new_user).empty? && !@metering_point.users.include?(@new_user)
        if MeteringPointUserRequest.create(user: @new_user, metering_point: @metering_point, mode: 'invitation')
          @metering_point.create_activity(key: 'metering_point_user_invitation.create', owner: current_user, recipient: @new_user)
          flash[:notice] = t('sent_metering_point_user_invitation_successfully')
        else
          flash[:error] = t('unable_to_send_metering_point_user_invitation')
        end
      else
        flash[:error] = t('metering_point_user_invitation_already_sent') + '. ' + t('waiting_for_accepting') + '.'
      end
    end
  end


  def remove_members
    @metering_point = MeteringPoint.find(params[:id])
    authorize_action_for @metering_point
  end
  authority_actions :remove_members => 'update'

  def remove_members_update
    @metering_point = MeteringPoint.find(params[:id])
    authorize_action_for @metering_point
    user_id = params[:user_id] || params[:metering_point][:user_id]
    @user = User.find(user_id)
    @user.remove_role(:member, @metering_point)
    if @user == current_user
      flash[:notice] = t('metering_point_left_successfully', metering_point_name: @metering_point.name)
    else
      flash[:notice] = t('user_removed_successfully', username: @user.name)
    end
    @metering_point.create_activity(key: 'metering_point_user_membership.cancel', owner: @user)
    respond_with @metering_point
  end
  authority_actions :remove_members_update => 'read'


  def add_manager
    @metering_point = MeteringPoint.find(params[:id])
    authorize_action_for @metering_point
    @collection = []
    [@metering_point.users + current_user.friends].flatten.uniq.each do |user|
      user.profile.nil? ? nil : @collection << user
    end
  end
  authority_actions :add_manager => 'update'

  def add_manager_update
    @metering_point = MeteringPoint.find(params[:id])
    authorize_action_for @metering_point
    @user = User.find(params[:metering_point][:user_id])
    if @user.has_role?(:manager, @metering_point)
      flash[:notice] = t('user_is_already_metering_point_manager', username: @user.name)
    else
      @user.add_role(:manager, @metering_point)
      @user.create_activity(key: 'user.appointed_metering_point_manager', owner: current_user, recipient: @metering_point)
      flash[:notice] = t('user_is_now_a_new_metering_point_manager', username: @user.name)
    end
  end
  authority_actions :add_manager_update => 'update'

  def remove_manager_update
    @metering_point = MeteringPoint.find(params[:id])
    authorize_action_for @metering_point
    if @metering_point.managers.size > 1
      current_user.remove_role(:manager, @metering_point)
      flash[:notice] = t('removed_role_successfully', role: t('metering_point_admin'), resource: @metering_point.name)
    else
      flash[:error] = t('you_can_not_be_removed_as_role_because_you_are_the_only_one_with_this_role', role: t('group_admin'))
    end
  end
  authority_actions :remove_manager_update => 'update'






  def chart
    @metering_point = MeteringPoint.find(params[:id])
    params[:containing_timestamp].nil? ? @containing_timestamp = Time.now.to_i*1000 : @containing_timestamp = params[:containing_timestamp]
    @cache_id = "/metering_points/#{params[:id]}/chart?resolution=#{params[:resolution]}&interval=#{@metering_point.get_cache_interval(params[:resolution], @containing_timestamp)}"
    @cache = Rails.cache.fetch(@cache_id)
    @data = @cache || @metering_point.chart_data(params[:resolution], @containing_timestamp)
    #@data = @metering_point.chart_data(params[:resolution], @containing_timestamp)
    @chart_data = []
    @chart_data << {
      data: @data,
      name: @metering_point.decorate.long_name
    }
    if @cache.nil?
      Rails.cache.write(@cache_id, @data, expires_in: @metering_point.get_cache_duration(params[:resolution]))
    end
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
    else
       latest_power = nil
       latest_timestamp = nil
    end
    online = latest_timestamp && latest_timestamp >= (Time.now - 60.seconds).to_i*1000 ? true : false
    if @cache.nil?
      Rails.cache.write(@cache_id, last_power, expires_in: 4.seconds)
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


  def chart_comments
    @metering_point = MeteringPoint.find(params[:id])
    @resolution = params[:resolution]
    @timestamp = params[:containing_timestamp]
    @comments = @metering_point.chart_comments(@resolution, @timestamp)
    result = []
    @comments.each do |comment|
      result << {comment_id: comment.id, user_image: comment.user.profile.decorate.picture('xs'), body: comment.body, chart_timestamp: comment.chart_timestamp.to_i*1000}
    end
    render json: { comments: result }
  end

  def widget
    response.headers.delete('X-Frame-Options') #Enables iFrames
    @metering_point                 = MeteringPoint.find(params[:id]).decorate
    @metering_point.readable_by_world? ? @metering_point : t('the_requested_content_is_not_public')
  end

  def edit_notifications
    @metering_point = MeteringPoint.find(params[:id])
  end
  #TODO: add authority_actions

  def edit_notifications_update
    @metering_point = MeteringPoint.find(params[:id])
    notify_when_comment_create = params[:metering_point][:notify_me_when_comment_create]
    notify_when_metering_point_exceeds = params[:metering_point][:notify_me_when_metering_point_exceeds]
    notify_when_metering_point_undershoots = params[:metering_point][:notify_me_when_metering_point_undershoots]
    notify_when_metering_point_offline = params[:metering_point][:notify_me_when_metering_point_offline]

    notification_unsubscriber_comment_create = NotificationUnsubscriber.by_user(current_user).by_resource(@metering_point).by_key('comment.create').first
    notification_unsubscriber_metering_point_exceeds = NotificationUnsubscriber.by_user(current_user).by_resource(@metering_point).by_key('metering_point.exceeds').first
    notification_unsubscriber_metering_point_undershoots = NotificationUnsubscriber.by_user(current_user).by_resource(@metering_point).by_key('metering_point.undershoots').first
    notification_unsubscriber_metering_point_offline = NotificationUnsubscriber.by_user(current_user).by_resource(@metering_point).by_key('metering_point.offline').first

    if notify_when_comment_create == "false"
      if !notification_unsubscriber_comment_create
        NotificationUnsubscriber.create(trackable: @metering_point, user: current_user, notification_key: 'comment.create', channel: 'email')
      end
    else
      notification_unsubscriber_comment_create.destroy if notification_unsubscriber_comment_create
    end
    if notify_when_metering_point_exceeds == "false"
      if !notification_unsubscriber_metering_point_exceeds
        NotificationUnsubscriber.create(trackable: @metering_point, user: current_user, notification_key: 'metering_point.exceeds', channel: 'email')
      end
    else
      notification_unsubscriber_metering_point_exceeds.destroy if notification_unsubscriber_metering_point_exceeds
    end
    if notify_when_metering_point_undershoots == "false"
      if !otification_unsubscriber_metering_point_undershoots
        NotificationUnsubscriber.create(trackable: @metering_point, user: current_user, notification_key: 'metering_point.undershoots', channel: 'email')
      end
    else
     notification_unsubscriber_metering_point_undershoots .destroy if notification_unsubscriber_metering_point_undershoots
    end
    if notify_when_metering_point_offline == "false"
      if !notification_unsubscriber_metering_point_offline
        NotificationUnsubscriber.create(trackable: @metering_point, user: current_user, notification_key: 'metering_point.offline', channel: 'email')
      end
    else
      notification_unsubscriber_metering_point_offline.destroy if notification_unsubscriber_metering_point_offline
    end
    flash[:notice] = t('settings_saved')
  end
  #TODO: add authority_actions


private
  def metering_point_params
    params.require(:metering_point).permit(
      :uid,
      :name,
      :image,
      :mode,
      :readable,
      :observe,
      :min_watt,
      :max_watt,
      :observe_offline,
      :virtual,
      :forecast_kwh_pa,
      :group_id,
      :user_ids => [],
      :device_ids => [],
      formula_parts_attributes: [:id, :operator, :metering_point_id, :operand_id, :_destroy]
    )
  end




end
