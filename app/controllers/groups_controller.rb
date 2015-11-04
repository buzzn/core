class GroupsController < ApplicationController
  before_filter :authenticate_user!, except: [:index, :show, :chart, :bubbles_data]
  respond_to :html, :js, :json

  def index
    group_ids = Group.where(readable: 'world').ids
    if user_signed_in?
      group_ids << Group.where(readable: 'community').ids
      group_ids << Group.with_role(:manager, current_user)

      current_user.friends.each do |friend|
        if friend
          Group.where(readable: 'friends').with_role(:manager, friend).each do |friend_group|
            group_ids << friend_group.id
          end
        end
      end
    end
    @groups  = Group.where(id: group_ids)
  end


  def show
    @group                          = Group.find(params[:id]).decorate

    # if url changed redirect to new url
    redirect_to(@group, status: :moved_permanently) if request.path != group_path(@group)

    @out_metering_points            = MeteringPoint.by_group(@group).outputs.decorate
    @in_metering_points             = MeteringPoint.by_group(@group).inputs.decorate
    @managers                       = @group.managers
    @energy_producers               = MeteringPoint.includes(:users).by_group(@group).outputs.decorate.collect(&:users).flatten
    @energy_consumers               = MeteringPoint.includes(:users).by_group(@group).inputs.decorate.collect(&:users).flatten
    @interested_members             = @group.users
    @group_metering_point_requests  = @group.received_group_metering_point_requests
    @all_comments                   = @group.root_comments
    @out_devices                    = @out_metering_points.collect(&:devices)
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
    #byebug
    @found_meter = Meter.where(manufacturer_product_serialnumber: params[:group][:new_meters])
    if @found_meter.any?
      @meter = @found_meter.first
      @metering_point = @meter.metering_points.first
      if GroupMeteringPointRequest.where(metering_point: @metering_point).where(group: @group).empty? && !@group.metering_points.include?(@metering_point)
        @group_invitation = GroupMeteringPointRequest.new(user: @metering_point.managers.first, metering_point: @metering_point, group: @group, mode: 'invitation')
        if @group_invitation.save
          @metering_point.managers.first.send_notification('info', t('new_group_metering_point_invitation'), @group.name, 0, profile_path(@metering_point.managers.first.profile))
          Notifier.send_email_new_group_metering_point_request(@metering_point.managers.first, current_user, @metering_point, @group, 'invitation')
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
    #byebug
    @group = Group.find(params[:id])
    @meter = Meter.new(manufacturer_product_serialnumber: params[:manufacturer_product_serialnumber])
    authorize_action_for @group
  end
  authority_actions :send_invitations_via_email => 'update'

  def send_invitations_via_email_update
    @group = Group.find(params[:id])
    authorize_action_for @group
    @manufacturer_product_serialnumber = params[:group][:manufacturer_product_serialnumber]
    #byebug
    if params[:group][:email] == "" #|| params[:group][:email_confirmation] == ""
      @group.errors.add(:email, I18n.t("cant_be_blank"))
    #  @group.errors.add(:email_confirmation,  I18n.t("cant_be_blank"))
      @meter = Meter.new(manufacturer_product_serialnumber: @manufacturer_product_serialnumber)
      render action: 'send_invitations_via_email'
 #   elsif params[:group][:email] != params[:group][:email_confirmation]
 #     @group.errors.add(:email, I18n.t("doesnt_match_with_confirmation"))
 #     @group.errors.add(:email_confirmation, I18n.t("doesnt_match_with_email"))
 #     @meter = Meter.new(manufacturer_product_serialnumber: @manufacturer_product_serialnumber)
 #     render action: 'send_invitations_via_email', manufacturer_product_serialnumber: @manufacturer_product_serialnumber
    else
      @email = params[:group][:email]
      @new_user = User.invite!({email: @email}, current_user)
      @metering_point = MeteringPoint.create!(mode: 'in', name: 'Wohnung', readable: 'friends')
      @metering_point.users << @new_user
      @new_user.add_role(:manager, @metering_point)
      @meter = Meter.create!(manufacturer_product_serialnumber: @manufacturer_product_serialnumber)
      @meter.metering_points << @metering_point
      @group.metering_points << @metering_point
      @group.create_activity key: 'group_metering_point_membership.create', owner: @new_user, recipient: @group
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



  def cancel_membership
    @group = Group.find(params[:id])
    @metering_point = MeteringPoint.find(params[:metering_point_id])
    if @group.metering_points.delete(@metering_point)
      @group.calculate_closeness
      flash[:notice] = t('metering_point_removed_successfully')
    else
      flash[:error] = t('unable_to_remove_metering_point')
    end
    redirect_to group_path(@group)
  end

  def bubbles_data
    @group = Group.find(params[:id])
    result = @group.bubbles_data(current_user)
    render json: result.to_json
  end

  def chart
    @cache_id = "/groups/#{params[:id]}/chart?resolution=#{params[:resolution]}&containing_timestamp=#{params[:containing_timestamp]}"
    @cache = Rails.cache.fetch(@cache_id)
    if @cache
      render json: @cache
    else
      resolution = params[:resolution]
      if resolution.nil?
        resolution = "day_to_minutes"
      end
      resolution_format = resolution
      render json: Group.find(params[:id]).chart(resolution_format, params[:containing_timestamp]).to_json
    end
  end

  def kiosk
    @group                          = Group.find(params[:id]).decorate
    @out_metering_points            = MeteringPoint.by_group(@group).outputs.decorate
    @in_metering_points             = MeteringPoint.by_group(@group).inputs.decorate
    @energy_producers               = MeteringPoint.includes(:users).by_group(@group).outputs.decorate.collect(&:users).flatten
    @energy_consumers               = MeteringPoint.includes(:users).by_group(@group).inputs.decorate.collect(&:users).flatten
    @interested_members             = @group.users
    @all_comments                   = @group.root_comments.order('created_at asc')
    @out_devices                    = @out_metering_points.collect(&:devices)
  end


  def get_scores
    @group = Group.find(params[:id])
    result = @group.get_scores(params[:resolution], params[:containing_timestamp])
    render json: result.to_json
  end





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






