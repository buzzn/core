class GroupsController < ApplicationController
  before_filter :authenticate_user!, except: [:index, :show, :chart, :bubbles_data, :widget, :kiosk]
  respond_to :html, :js, :json

  def index
    group_ids = Group.readable_group_ids_by_user(current_user)
    @groups  = Group.where(id: group_ids).search(params[:search]).decorate
  end


  def show
    @group                          = Group.find(params[:id]).decorate

    # if url changed redirect to new url
    redirect_to(group_path(@group), status: :moved_permanently) if request.path != group_path(@group)

    @out_metering_points            = MeteringPoint.by_group(@group).outputs.without_externals.decorate
    @in_metering_points             = MeteringPoint.by_group(@group).inputs.without_externals.decorate
    @managers                       = @group.managers
    @energy_producers               = MeteringPoint.by_group(@group).outputs.without_externals.decorate.collect(&:members).flatten.uniq
    @energy_consumers               = MeteringPoint.by_group(@group).inputs.without_externals.decorate.collect(&:members).flatten.uniq
    @group_metering_point_requests  = @group.received_group_metering_point_requests
    @all_comments                   = @group.root_comments
    @out_devices                    = @out_metering_points.collect(&:devices)
    @activities                     = @group.activities.group_joins
    @activities_and_comments        = (@all_comments + @activities).sort_by!(&:created_at).reverse!

    authorize_action_for(@group)
  end


  def new
    @group = Group.new
    authorize_action_for @group
  end

  def create
    @group = Group.new(group_params)
    authorize_action_for @group
    if @group.save
      current_user.add_role :manager, @group
      flash[:notice] = t('group_created_successfully')
      respond_with @group.decorate
    else
      flash[:error] = t('failed_to_create_group')
      render :new
    end
  end



  def edit
    @group = Group.find(params[:id]).decorate
    authorize_action_for(@group)
  end

  def update
    Group.public_activity_off
    @group = Group.find(params[:id])
    authorize_action_for @group
    if @group.update_attributes(group_params)
      respond_with @group
    else
      render :edit
    end
    Group.public_activity_on
  end

  def send_invitations
    @group = Group.find(params[:id])
    authorize_action_for @group
  end
  authority_actions :send_invitations => 'update'

  def send_invitations_update
    @group = Group.find(params[:id])
    authorize_action_for @group
    @found_meter = Meter.where(manufacturer_product_serialnumber: params[:group][:new_meters])
    if @found_meter.any?
      @meter = @found_meter.first
      @metering_point = @meter.metering_points.first
      if GroupMeteringPointRequest.where(metering_point: @metering_point).where(group: @group).empty? && !@group.metering_points.without_externals.include?(@metering_point)
        @group_invitation = GroupMeteringPointRequest.new(user: @metering_point.managers.first, metering_point: @metering_point, group: @group, mode: 'invitation')
        if @group_invitation.save
          @group.create_activity(key: 'group_metering_point_invitation.create', owner: current_user, recipient: @metering_point)
          flash[:notice] = t('sent_group_metering_point_invitation_successfully')
        else
          flash[:error] = t('unable_to_send_group_metering_point_invitation')
        end
      else
        flash[:arror] = t('group_metering_point_invitation_already_sent') + '. ' + t('waiting_for_accepting') + '.'
      end
    else
      redirect_to send_invitations_via_email_group_path(manufacturer_product_serialnumber: params[:group][:new_meters])
    end
  end
  authority_actions :send_invitations_update => 'update'

  def send_invitations_via_email
    @group = Group.find(params[:id])
    @meter = Meter.new(manufacturer_product_serialnumber: params[:manufacturer_product_serialnumber])
    authorize_action_for @group
  end
  authority_actions :send_invitations_via_email => 'update'

  def send_invitations_via_email_update
    @group = Group.find(params[:id])
    authorize_action_for @group
    @manufacturer_product_serialnumber = params[:group][:manufacturer_product_serialnumber]
    if params[:group][:email] == ""
      @group.errors.add(:email, I18n.t("cant_be_blank"))
      @meter = Meter.new(manufacturer_product_serialnumber: @manufacturer_product_serialnumber)
      render action: 'send_invitations_via_email'
    else
      @email = params[:group][:email]
      @new_user = User.invite!({email: @email, invitation_message: params[:group][:message]}, current_user)
      @metering_point = MeteringPoint.create!(mode: 'in', name: 'Wohnung', readable: 'friends')
      @new_user.add_role(:member, @metering_point)
      @new_user.add_role(:manager, @metering_point)
      @meter = Meter.create!(manufacturer_product_serialnumber: @manufacturer_product_serialnumber)
      @meter.metering_points << @metering_point
      @group.metering_points << @metering_point
      @group.create_activity key: 'group_metering_point_membership.create', owner: @new_user, recipient: @metering_point
      current_user.create_activity key: 'user.create_platform_invitation', owner: current_user, recipient: @new_user
      @meter.save!
      flash[:notice] = t('invitation_sent_successfully_to', email: @email)
    end
  end
  authority_actions :send_invitations_via_email_update => 'update'

  def destroy
    @group = Group.find(params[:id])
    authorize_action_for @group
    @group.destroy
    flash[:notice] = t('group_destroyed_successfully')
    respond_with current_user.profile
  end



  def remove_members
    @group = Group.find(params[:id])
    authorize_action_for @group
  end
  authority_actions :remove_members => 'update'

  def remove_members_update
    @group = Group.find(params[:id])
    metering_point_id = params[:metering_point_id] || params[:group][:metering_point_id]
    @metering_point = MeteringPoint.find(metering_point_id)
    if @group.metering_points.delete(@metering_point)
      @group.create_activity(key: 'group_metering_point_membership.cancel', owner: @metering_point.managers.first, recipient: @metering_point)
      flash[:notice] = t('metering_point_removed_successfully')
    else
      flash[:error] = t('unable_to_remove_metering_point')
    end
    respond_with @group
  end


  def add_manager
    @group = Group.find(params[:id])
    authorize_action_for @group
    @collection = []
    [@group.involved + current_user.friends].flatten.uniq.each do |user|
      user.profile.nil? ? nil : @collection << user
    end
  end
  authority_actions :add_manager => 'update'

  def add_manager_update
    @group = Group.find(params[:id])
    authorize_action_for @group
    @user = User.find(params[:group][:user_id])
    if @user.has_role?(:manager, @group)
      flash[:notice] = t('user_is_already_group_manager', username: @user.name)
    else
      @user.add_role(:manager, @group)
      @user.create_activity(key: 'user.appointed_group_manager', owner: current_user, recipient: @group)
      flash[:notice] = t('user_is_now_a_new_group_manager', username: @user.name)
    end
  end
  authority_actions :add_manager_update => 'update'

  def remove_manager_update
    @group = Group.find(params[:id])
    authorize_action_for @group
    if @group.managers.size > 1
      current_user.remove_role(:manager, @group)
      flash[:notice] = t('removed_role_successfully', role: t('group_admin'), resource: @group.name)
    else
      flash[:error] = t('you_can_not_be_removed_as_role_because_you_are_the_only_one_with_this_role', role: t('group_admin'))
    end
  end
  authority_actions :remove_manager_update => 'update'


  def bubbles_data
    @group = Group.find(params[:id])
    @cache_id = "/groups/#{params[:id]}/bubbles_data"
    @cache = Rails.cache.fetch(@cache_id)
    @energy_data = @cache || @group.bubbles_energy_data
    @personal_data = @group.bubbles_personal_data(current_user)
    if @cache.nil?
      Rails.cache.write(@cache_id, @energy_data, expires_in: 9.seconds)
    end
    #merge personal with energy data
    energy_data_in_arr = @energy_data[:in]
    personal_data_in_arr = @personal_data[:in]
    energy_data_out_arr = @energy_data[:out][:children]
    personal_data_out_arr = @personal_data[:out]
    result_in = []
    result_out = []
    energy_data_in_arr.each do |energy_data_entry|
      personal_data_in_arr.each do |personal_data_entry|
        if energy_data_entry[:metering_point_id] == personal_data_entry[:metering_point_id]
          result_in.push(energy_data_entry.merge(personal_data_entry))
          break
        end
      end
    end
    energy_data_out_arr.each do |energy_data_entry|
      personal_data_out_arr.each do |personal_data_entry|
        if energy_data_entry[:metering_point_id] == personal_data_entry[:metering_point_id]
          result_out.push(energy_data_entry.merge(personal_data_entry))
          break
        end
      end
    end
    result = {:in => result_in, :out => { :name => "Gesamterzeugung", :children => result_out}}
    render json: result
  end

  def chart
    @group = Group.find(params[:id])
    @resolution = params[:resolution] || "day_to_minutes"
    @cache_id = "/groups/#{params[:id]}/chart?resolution=#{@resolution}&interval=#{@group.get_cache_interval(@resolution, params[:containing_timestamp])}"
    @cache = Rails.cache.fetch(@cache_id)
    @data = @cache || @group.chart(@resolution, params[:containing_timestamp])
    #@data = @group.chart(@resolution, params[:containing_timestamp])
    if @cache.nil?
      Rails.cache.write(@cache_id, @data, expires_in: @group.get_cache_duration(@resolution))
    end
    render json: @data.to_json
  end

  def kiosk
    #response.headers.delete('X-Frame-Options') #Enables iFrames
    @group                          = Group.find(params[:id]).decorate

    @all_comments                   = @group.root_comments
    @activities                     = @group.activities.group_joins
    @activities_and_comments        = (@all_comments + @activities).sort_by!(&:created_at).reverse!

    if @group.readable_by_world?
      return @group
    else
      if user_signed_in?
        if @group.readable_by_community?
          return @group
        else
          authorize_action_for(@group)
        end
      else
        redirect_to root_path
      end
    end
  end
  authority_actions :kiosk => 'read'

  def widget
    response.headers.delete('X-Frame-Options') #Enables iFrames
    @group                          = Group.find(params[:id]).decorate
    @group.readable_by_world? ? @group : t('the_requested_content_is_not_public')
  end


  def get_scores
    @group = Group.find(params[:id])
    result = @group.get_scores(params[:resolution], params[:containing_timestamp].to_i)
    render json: result.to_json
  end

  def chart_comments
    @group = Group.find(params[:id])
    @resolution = params[:resolution]
    @timestamp = params[:containing_timestamp]
    @comments = @group.chart_comments(@resolution, @timestamp)
    result = []
    @comments.each do |comment|
      result << {comment_id: comment.id, user_image: comment.user.profile.decorate.picture('xs'), body: comment.body, chart_timestamp: comment.chart_timestamp.to_i*1000}
    end
    render json: { comments: result }
  end



  def edit_notifications
    @group = Group.find(params[:id])
  end
  #TODO: add authority_actions

  def edit_notifications_update
    @group = Group.find(params[:id])
    notify_when_comment_create = params[:group][:notify_me_when_comment_create]

    notification_unsubscriber_comment_create = NotificationUnsubscriber.by_user(current_user).by_resource(@group).by_key('comment.create').first

    if notify_when_comment_create == "false"
      if !notification_unsubscriber_comment_create
        NotificationUnsubscriber.create(trackable: @group, user: current_user, notification_key: 'comment.create', channel: 'email')
      end
    else
      notification_unsubscriber_comment_create.destroy if notification_unsubscriber_comment_create
    end
    flash[:notice] = t('settings_saved')
  end
  #TODO: add authority_actions





private
  def group_params
    params.require(:group).permit(
      :name,
      :image,
      :logo,
      :mode,
      :private,
      :website,
      :description,
      :readable,
      :metering_point_ids => []
    )
  end



end
