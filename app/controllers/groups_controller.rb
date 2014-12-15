class GroupsController < InheritedResources::Base
  respond_to :html, :js

  def show
    @group                          = Group.includes(:assets).find(params[:id]).decorate
    @metering_points                = MeteringPoint.includes(:users).by_group_id_and_modes(@group.id, ['out','in']).flatten.uniq
    @energy_producers               = MeteringPoint.includes(:users).by_group_id_and_modes(@group.id, ['out']).decorate.collect(&:users).flatten
    @energy_consumers               = MeteringPoint.includes(:users).by_group_id_and_modes(@group.id, ['in']).decorate.collect(&:users).flatten
    @interested_members             = @group.users

    @group_metering_point_requests  = @group.received_group_metering_point_requests

    @all_users                      = User.all.decorate
    @all_groups                     = Group.includes(:assets).all.decorate

    @all_comments                   = @group.comment_threads.order('created_at desc')
    @new_comment                    = Comment.build_from(@group, current_user.id, "") if user_signed_in?

    if @metering_points
      gon.push({ register_ids: @metering_points.collect(&:registers).flatten.collect(&:id) })
    else
      gon.push({ register_ids: [] })
    end
  end

  def edit
    @group = Group.find(params[:id]).decorate
    authorize_action_for(@group)
    edit!
  end

  def create
    create! do |success, failure|
      success.js {
        current_user.add_role :manager, @group
        @group = GroupDecorator.new(@group)
        @group
      }
      failure.js { render :new }
    end
  end

  def destroy
    destroy! do |failure|
      failure.js {
        @group = LocationDecorator.new(@group)
        flash[:error] = t('cannot_delete_group_while_running_contracts_exists')
        @group
      }
    end
  end

  def cancel_membership
    @group = Group.find(params[:id])
    @metering_point = MeteringPoint.find(params[:metering_point_id])
    @group.metering_points.delete(@metering_point)
    redirect_to group_path(@group)
  end

  def permitted_params
    params.permit(:group => init_permitted_params)
  end

  private

  def init_permitted_params
    [
      :id,
      :name,
      :mode,
      :private,
      :description,
      :metering_point_ids => [],
      assets_attributes: [:id, :image, :description, :assetable_id, :assetable_type]
    ]
  end
end
