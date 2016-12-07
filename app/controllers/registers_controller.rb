class RegistersController < ApplicationController
  before_filter :authenticate_user!, except: [:show, :chart, :latest_fake_data, :latest_power, :widget]
  respond_to :html, :json, :js



  def show
    # the Register::Base.find is just to raise NotFoundError
    @register                 = (Register::Base.where(id: params[:id]).anonymized(current_user).first || Register::Base.find(params[:id])).decorate
    @members                        = @register.members.registered
    @managers                       = @register.managers.registered
    @devices                        = @register.devices
    @group                          = @register.group
    @meter                          = @register.meter
    @requests                       = @register.received_user_requests
    @all_comments                   = @register.root_comments
    @activities                     = @register.activities.register_joins
    @activities_and_comments        = (@all_comments + @activities).sort_by!(&:created_at).reverse!
    Browser.modern_rules.clear
    Browser.modern_rules << -> b { b.firefox? && b.version.to_i >= 41 }
    browser = Browser.new(ua: request.user_agent, accept_language: request.accept_language)

    authorize_action_for(@register, :group_inheritance)
  end




  def new
    @register = Register::Base.new(mode: 'in')
    authorize_action_for @register
    2.times{@register.formula_parts.build}
  end


  def create
    @register = Register::Base.new(register_params)
    authorize_action_for @register
    if @register.save
      current_user.add_role(:manager, @register)
      #@register.create_activity key: 'register.create', owner: current_user
      respond_with @register.decorate
      flash[:notice] = t('register_created_successfully')
    else
      render :new
    end
  end


  def edit
    @register = Register::Base.find(params[:id])
    authorize_action_for(@register)
  end


  def update
    @register = Register::Base.find(params[:id])
    authorize_action_for @register
    if @register.update_attributes(register_params)
      respond_with @register
    else
      render :edit
    end
  end

  def destroy
    @register = Register::Base.find(params[:id])
    authorize_action_for @register
    @register.destroy
    respond_with current_user.profile
    flash[:notice] = t('register_deleted_successfully')
  end



  def edit_users
    # TODO: insert added user directly
    @register = Register::Base.find(params[:id]).decorate
    authorize_action_for(@register, action: 'edit_users')
  end
  authority_actions :edit_users => 'update'



  def edit_devices
    # TODO: insert added device directly
    @register = Register::Base.find(params[:id]).decorate
    authorize_action_for(@register, action: 'edit_devices')
  end
  authority_actions :edit_devices => 'update'

  def edit_readings
    @register = Register::Base.find(params[:id]).decorate
    @readings = @register.submitted_readings_by_user
    authorize_action_for(@register, action: 'edit_devices')
  end
  authority_actions :edit_readings => 'update'

  def send_invitations
    @register = Register::Base.find(params[:id])
  end

  def send_invitations_update
    @register = Register::Base.find(params[:id])
    if params[:register][:invite_via_email] == "1"
      if params[:register][:email] == ""
        @register.errors.add(:email, I18n.t("cant_be_blank"))
        render action: 'send_invitations', invite_via_email: 'checked'
      else
        @email = params[:register][:email]
        @existing_users = User.unscoped.where(email: @email)
        if @existing_users.any?
          if RegisterUserRequest.where(register: @register).where(user: @existing_users.first).empty? && !@register.users.include?(@existing_users.first)
            @register_user_request = RegisterUserRequest.new(user: @existing_users.first, register: @register, mode: 'invitation')
            if @register_user_request.save
              @register.create_activity(key: 'register_user_invitation.create', owner: current_user, recipient: @existing_users.first)
              flash[:notice] = t('sent_register_user_invitation_successfully')
            else
              flash[:error] = t('unable_to_send_register_user_invitation')
            end
          else
            flash[:error] = t('register_user_invitation_already_sent') + '. ' + t('waiting_for_accepting') + '.'
          end
        else
          @new_user = User.unscoped.invite!({email: @email, invitation_message: params[:register][:message]}, current_user)
          current_user.create_activity key: 'user.create_platform_invitation', owner: current_user, recipient: @new_user
          @new_user.add_role(:member, @register)
          current_user.friends.include?(@new_user) ? nil : current_user.friends << @new_user
          @register.save!
          flash[:notice] = t('invitation_sent_successfully_to', email: @email)
        end
      end
    else
      @new_user = User.find(params[:register][:new_users])
      if RegisterUserRequest.where(register: @register).where(user: @new_user).empty? && !@register.users.include?(@new_user)
        if RegisterUserRequest.create(user: @new_user, register: @register, mode: 'invitation')
          @register.create_activity(key: 'register_user_invitation.create', owner: current_user, recipient: @new_user)
          flash[:notice] = t('sent_register_user_invitation_successfully')
        else
          flash[:error] = t('unable_to_send_register_user_invitation')
        end
      else
        flash[:error] = t('register_user_invitation_already_sent') + '. ' + t('waiting_for_accepting') + '.'
      end
    end
  end


  def remove_members
    @register = Register::Base.find(params[:id])
    authorize_action_for @register
  end
  authority_actions :remove_members => 'update'

  def remove_members_update
    @register = Register::Base.find(params[:id])
    authorize_action_for @register
    user_id = params[:user_id] || params[:register][:user_id]
    @user = User.find(user_id)
    @user.remove_role(:member, @register)
    if @user == current_user
      flash[:notice] = t('register_left_successfully', register_name: @register.name)
    else
      flash[:notice] = t('user_removed_successfully', username: @user.name)
    end
    @register.create_activity(key: 'register_user_membership.cancel', owner: @user)
    respond_with @register
  end
  authority_actions :remove_members_update => 'read'


  def add_manager
    @register = Register::Base.find(params[:id])
    authorize_action_for @register
    @collection = []
    [@register.users + current_user.friends].flatten.uniq.each do |user|
      user.profile.nil? ? nil : @collection << user
    end
  end
  authority_actions :add_manager => 'update'

  def add_manager_update
    @register = Register::Base.find(params[:id])
    authorize_action_for @register
    @user = User.find(params[:register][:user_id])
    if @user.has_role?(:manager, @register)
      flash[:notice] = t('user_is_already_register_manager', username: @user.name)
    else
      @user.add_role(:manager, @register)
      @user.create_activity(key: 'user.appointed_register_manager', owner: current_user, recipient: @register)
      flash[:notice] = t('user_is_now_a_new_register_manager', username: @user.name)
    end
  end
  authority_actions :add_manager_update => 'update'

  def remove_manager_update
    @register = Register::Base.find(params[:id])
    authorize_action_for @register
    if @register.managers.size > 1
      current_user.remove_role(:manager, @register)
      flash[:notice] = t('removed_role_successfully', role: t('register_admin'), resource: @register.name)
    else
      flash[:error] = t('you_can_not_be_removed_as_role_because_you_are_the_only_one_with_this_role', role: t('group_admin'))
    end
  end
  authority_actions :remove_manager_update => 'update'


  def get_scores
    @register = Register::Base.find(params[:id])
    resolution_format = params[:resolution]
    containing_timestamp = params[:containing_timestamp]
    if resolution_format.nil?
      resolution_format = "year"
    end
    if containing_timestamp.nil?
      containing_timestamp = Time.current.to_i * 1000
    end

    if resolution_format == 'day'
      sufficiency = @register.scores.sufficiencies.dayly.at(containing_timestamp).first
      fitting = @register.scores.fittings.dayly.at(containing_timestamp).first
    elsif resolution_format == 'month'
      sufficiency = @register.scores.sufficiencies.monthly.at(containing_timestamp).first
      fitting = @register.scores.fittings.monthly.at(containing_timestamp).first
    elsif resolution_format == 'year'
      sufficiency = @register.scores.sufficiencies.yearly.at(containing_timestamp).first
      fitting = @register.scores.fittings.yearly.at(containing_timestamp).first
    end
    sufficiency.nil? ? sufficiency_value = 0 : sufficiency_value = sufficiency.value
    fitting.nil? ? fitting_value = 0 : fitting_value = fitting.value
    render json: { sufficiency: sufficiency_value, fitting: fitting_value }.to_json
  end


  def chart_comments
    @register = Register::Base.find(params[:id])
    @resolution = params[:resolution]
    @timestamp = params[:containing_timestamp]
    @comments = @register.chart_comments(@resolution, @timestamp)
    result = []
    @comments.each do |comment|
      result << {comment_id: comment.id, user_image: comment.user.profile.decorate.picture('xs'), body: comment.body, chart_timestamp: comment.chart_timestamp.to_i*1000}
    end
    render json: { comments: result }
  end

  def widget
    response.headers.delete('X-Frame-Options') #Enables iFrames
    @register                 = Register::Base.find(params[:id]).decorate
    @register.readable_by_world? ? @register : t('the_requested_content_is_not_public')
  end

  def edit_notifications
    @register = Register::Base.find(params[:id])
  end
  #TODO: add authority_actions

  def edit_notifications_update
    @register = Register::Base.find(params[:id])
    notify_when_comment_create = params[:register][:notify_me_when_comment_create]
    notify_when_register_exceeds = params[:register][:notify_me_when_register_exceeds]
    notify_when_register_undershoots = params[:register][:notify_me_when_register_undershoots]
    notify_when_register_offline = params[:register][:notify_me_when_register_offline]

    notification_unsubscriber_comment_create = NotificationUnsubscriber.by_user(current_user).by_resource(@register).by_key('comment.create').first
    notification_unsubscriber_register_exceeds = NotificationUnsubscriber.by_user(current_user).by_resource(@register).by_key('register.exceeds').first
    notification_unsubscriber_register_undershoots = NotificationUnsubscriber.by_user(current_user).by_resource(@register).by_key('register.undershoots').first
    notification_unsubscriber_register_offline = NotificationUnsubscriber.by_user(current_user).by_resource(@register).by_key('register.offline').first

    if notify_when_comment_create == "0"
      if !notification_unsubscriber_comment_create
        NotificationUnsubscriber.create(trackable: @register, user: current_user, notification_key: 'comment.create', channel: 'email')
      end
    else
      notification_unsubscriber_comment_create.destroy if notification_unsubscriber_comment_create
    end
    if notify_when_register_exceeds == "0"
      if !notification_unsubscriber_register_exceeds
        NotificationUnsubscriber.create(trackable: @register, user: current_user, notification_key: 'register.exceeds', channel: 'email')
      end
    else
      notification_unsubscriber_register_exceeds.destroy if notification_unsubscriber_register_exceeds
    end
    if notify_when_register_undershoots == "0"
      if !notification_unsubscriber_register_undershoots
        NotificationUnsubscriber.create(trackable: @register, user: current_user, notification_key: 'register.undershoots', channel: 'email')
      end
    else
     notification_unsubscriber_register_undershoots .destroy if notification_unsubscriber_register_undershoots
    end
    if notify_when_register_offline == "0"
      if !notification_unsubscriber_register_offline
        NotificationUnsubscriber.create(trackable: @register, user: current_user, notification_key: 'register.offline', channel: 'email')
      end
    else
      notification_unsubscriber_register_offline.destroy if notification_unsubscriber_register_offline
    end
    flash[:notice] = t('settings_saved')
  end
  #TODO: add authority_actions

  def get_reading
    @register = Register::Base.find(params[:register_id])
  end

  def get_reading_update
    render :get_reading_update
    #render json: { data: [timestamp: Time.current.to_i*1000, reading: 12345]}
  end

  def latest_fake_data
    @register = Register::Base.find(params[:id])
    @cache_id = "/registers/#{params[:id]}/latest_fake_data"
    @cache = Rails.cache.fetch(@cache_id)
    @latest_fake_data = @cache || @register.latest_fake_data
    render json: @latest_fake_data.to_json
  end

private
  def register_params
    params.require(:register).permit(
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
      formula_parts_attributes: [:id, :operator, :register_id, :operand_id, :_destroy]
    )
  end




end
