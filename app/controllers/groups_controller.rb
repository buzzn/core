class GroupsController < InheritedResources::Base
  respond_to :html, :js

  def show
    @group                          = Group.find(params[:id]).decorate
    @metering_points                = MeteringPoint.by_group_id_and_modes(@group.id, ['out','in']).flatten.uniq
    @energy_producers               = MeteringPoint.by_group_id_and_modes(@group.id, ['out']).decorate.collect(&:users).flatten
    @energy_consumers               = MeteringPoint.by_group_id_and_modes(@group.id, ['in']).decorate.collect(&:users).flatten
    @interested_members             = @group.users

    @group_metering_point_requests  = @group.received_group_metering_point_requests
    @registers                      = @group.metering_points.collect(&:registers)

    @all_users                      = User.all.decorate
    @all_groups                     = Group.all.decorate

    @all_comments                   = @group.comment_threads.order('created_at desc')
    @new_comment                    = Comment.build_from(@group, current_user.id, "") if user_signed_in?

    # TODO change to AJAX
    @register_charts = []
    @registers.each do |register|
      if register.first == register.last
        @register_charts << register.first.day_to_hours
      else
        @register_charts << register.first.day_to_hours
        @register_charts << register.last.day_to_hours
      end
    end
    gon.push({ register_charts: @register_charts,
               end_of_day: Time.now.end_of_day.to_i * 1000
            })
  end

  def edit
    @group = Group.find(params[:id]).decorate
    authorize_action_for(@group)
    edit!
  end

  def create
    create! do |success, failure|
      current_user.add_role :manager, @group
      @group = GroupDecorator.new(@group)
      success.js { @group }
      failure.js { render :new }
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
      assets_attributes: [:id, :image, :description, :assetable_id, :assetable_type],
    ]
  end
end
