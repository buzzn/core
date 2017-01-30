class GroupsController < ApplicationController
  before_filter :authenticate_user!, except: [:index, :show, :chart, :widget, :kiosk]
  respond_to :html, :js, :json

  def index
    group_ids = Group::Base.readable_group_ids_by_user(current_user)
    @groups  = Group::Base.where(id: group_ids).search(params[:search]).decorate
  end


  def show
    @group                          = Group::Base.find(params[:id]).decorate

    # if url changed redirect to new url
    redirect_to(group_path(@group), status: :moved_permanently) if request.path != group_path(@group)

    @output_registers            = Register::Base.by_group(@group).outputs.without_externals.decorate
    @input_registers             = Register::Base.by_group(@group).inputs.without_externals.decorate
    @managers                 = @group.managers
    @energy_producers         = @group.energy_producers.decorate
    @energy_consumers         = @group.energy_consumers.decorate
    @group_register_requests  = @group.received_group_register_requests
    @all_comments             = @group.root_comments
    @out_devices              = @output_registers.collect(&:devices)
    @activities               = @group.activities.group_joins
    @activities_and_comments  = (@all_comments + @activities).sort_by!(&:created_at).reverse!

    authorize_action_for(@group)
  end


  def new
    @group = Group::Base.new
    authorize_action_for @group
  end

  def create
    @group = Group::Base.new(group_params)
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
    @group = Group::Base.find(params[:id]).decorate
    authorize_action_for(@group)
  end

  def update
    Group::Base.public_activity_off
    @group = Group::Base.find(params[:id])
    authorize_action_for @group
    if @group.update_attributes(group_params)
      respond_with @group
    else
      render :edit
    end
    Group::Base.public_activity_on
  end

  def send_invitations
    @group = Group::Base.find(params[:id])
    authorize_action_for @group
  end
  authority_actions :send_invitations => 'update'

  def send_invitations_update
    @group = Group::Base.find(params[:id])
    authorize_action_for @group
    if params[:group][:add_own_register] == "1"
      @register = Register::Base.find(params[:group][:register_id])
      if @register.group_id != @group.id
        @register.group = @group
        @register.save
        flash[:notice] = t('register_added_successfully')
      else
        flash[:notice] = t('your_register_is_already_part_of_another_group')
      end
    else
      @found_meter = Meter::Base.where(manufacturer_product_serialnumber: params[:group][:new_meters])
      if @found_meter.any?
        @meter = @found_meter.first
        @register = @meter.registers.first
        if GroupRegisterRequest.where(register: @register).where(group: @group).empty? && !@group.registers.without_externals.include?(@register)
          @group_invitation = GroupRegisterRequest.new(user: @register.managers.first, register: @register, group: @group, mode: 'invitation')
          if @group_invitation.save
            @group.create_activity(key: 'group_register_invitation.create', owner: current_user, recipient: @register)
            flash[:notice] = t('sent_group_register_invitation_successfully')
          else
            flash[:error] = t('unable_to_send_group_register_invitation')
          end
        else
          flash[:arror] = t('group_register_invitation_already_sent') + '. ' + t('waiting_for_accepting') + '.'
        end
      else
        redirect_to send_invitations_via_email_group_path(manufacturer_product_serialnumber: params[:group][:new_meters])
      end
    end

  end
  authority_actions :send_invitations_update => 'update'

  def send_invitations_via_email
    @group = Group::Base.find(params[:id])
    @meter = Meter::Base.new(manufacturer_product_serialnumber: params[:manufacturer_product_serialnumber])
    authorize_action_for @group
  end
  authority_actions :send_invitations_via_email => 'update'

  def send_invitations_via_email_update
    @group = Group::Base.find(params[:id])
    authorize_action_for @group
    @manufacturer_product_serialnumber = params[:group][:manufacturer_product_serialnumber]
    if params[:group][:email] == ""
      @group.errors.add(:email, I18n.t("cant_be_blank"))
      @meter = Meter::Base.new(manufacturer_product_serialnumber: @manufacturer_product_serialnumber)
      render action: 'send_invitations_via_email'
    else
      @email = params[:group][:email]
      @new_user = User.invite!({email: @email, invitation_message: params[:group][:message]}, current_user)
      @register = Register::Base.create!(mode: 'in', name: 'Wohnung', readable: 'friends')
      @new_user.add_role(:member, @register)
      @new_user.add_role(:manager, @register)
      @meter = Meter::Base.create!(manufacturer_product_serialnumber: @manufacturer_product_serialnumber)
      @meter.registers << @register
      @group.registers << @register
      @group.create_activity key: 'group_register_membership.create', owner: @new_user, recipient: @register
      current_user.create_activity key: 'user.create_platform_invitation', owner: current_user, recipient: @new_user
      @meter.save!
      flash[:notice] = t('invitation_sent_successfully_to', email: @email)
    end
  end
  authority_actions :send_invitations_via_email_update => 'update'

  def destroy
    @group = Group::Base.find(params[:id])
    authorize_action_for @group
    @group.destroy
    flash[:notice] = t('group_destroyed_successfully')
    respond_with current_user.profile
  end



  def remove_members
    @group = Group::Base.find(params[:id])
    authorize_action_for @group
  end
  authority_actions :remove_members => 'update'

  def remove_members_update
    @group = Group::Base.find(params[:id])
    register_id = params[:register_id] || params[:group][:register_id]
    @register = Register::Base.find(register_id)
    if @group.registers.delete(@register)
      @group.create_activity(key: 'group_register_membership.cancel', owner: @register.managers.first, recipient: @register)
      flash[:notice] = t('register_removed_successfully')
    else
      flash[:error] = t('unable_to_remove_register')
    end
    respond_with @group
  end


  def add_manager
    @group = Group::Base.find(params[:id])
    authorize_action_for @group
    @collection = []
    [@group.involved + current_user.friends].flatten.uniq.each do |user|
      user.profile.nil? ? nil : @collection << user
    end
  end
  authority_actions :add_manager => 'update'

  def add_manager_update
    @group = Group::Base.find(params[:id])
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
    @group = Group::Base.find(params[:id])
    authorize_action_for @group
    if @group.managers.size > 1
      current_user.remove_role(:manager, @group)
      flash[:notice] = t('removed_role_successfully', role: t('group_admin'), resource: @group.name)
    else
      flash[:error] = t('you_can_not_be_removed_as_role_because_you_are_the_only_one_with_this_role', role: t('group_admin'))
    end
  end
  authority_actions :remove_manager_update => 'update'


  def kiosk
    #response.headers.delete('X-Frame-Options') #Enables iFrames
    @group                          = Group::Base.find(params[:id]).decorate

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
    @group                          = Group::Base.find(params[:id]).decorate
    @group.readable_by_world? ? @group : t('the_requested_content_is_not_public')
  end


  def get_scores
    @group = Group::Base.find(params[:id])
    result = @group.get_scores(params[:resolution], params[:containing_timestamp].to_i)
    render json: result.to_json
  end

  def chart_comments
    @group = Group::Base.find(params[:id])
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
    @group = Group::Base.find(params[:id])
  end
  #TODO: add authority_actions

  def edit_notifications_update
    @group = Group::Base.find(params[:id])
    notify_when_comment_create = params[:group][:notify_me_when_comment_create]

    notification_unsubscriber_comment_create = NotificationUnsubscriber.by_user(current_user).by_resource(@group).by_key('comment.create').first

    if notify_when_comment_create == "0"
      if !notification_unsubscriber_comment_create
        NotificationUnsubscriber.create(trackable: @group, user: current_user, notification_key: 'comment.create', channel: 'email')
      end
    else
      notification_unsubscriber_comment_create.destroy if notification_unsubscriber_comment_create
    end
    flash[:notice] = t('settings_saved')
  end
  #TODO: add authority_actions

  def finalize_registers
    @group = Group::Base.find(params[:id])
    if current_user && current_user.has_role?(:admin)
      if @group.finalize_registers
        flash[:notice] = t('settings_saved')
      else
        flash[:error] = t('unable_to_save_settings')
      end
    end
  end





private
  def group_params
    params.require(:group_base).permit(
      :name,
      :image,
      :logo,
      :mode,
      :private,
      :website,
      :description,
      :readable,
      :add_own_register,
      :register_ids => []
    )
  end



end
