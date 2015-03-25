class GroupsController < ApplicationController
  respond_to :html, :js, :json

  def index
    @groups = Group.all.decorate
  end


  def show
    @group                          = Group.find(params[:id]).decorate
    @out_metering_points            = MeteringPoint.by_group(@group).outputs.decorate
    @in_metering_points             = MeteringPoint.by_group(@group).inputs.decorate
    @energy_producers               = MeteringPoint.includes(:users).by_group(@group).outputs.decorate.collect(&:users).flatten
    @energy_consumers               = MeteringPoint.includes(:users).by_group(@group).inputs.decorate.collect(&:users).flatten
    @interested_members             = @group.users
    @group_metering_point_requests  = @group.received_group_metering_point_requests
    @all_comments                   = @group.root_comments.order('created_at asc')
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
      respond_with @group.decorate
    else
      render :new
    end
  end



  def edit
    @group = Group.find(params[:id]).decorate
    authorize_action_for(@group)
  end

  def update
    @group = Group.find(params[:id])
    authorize_action_for @group
    if @group.update_attributes(group_params)
      respond_with @group
    else
      render :edit
    end
  end


  def destroy
    @group = Group.find(params[:id])
    authorize_action_for @group
    @group.destroy
    respond_with current_user.profile
  end



  def cancel_membership
    @group = Group.find(params[:id])
    @metering_point = MeteringPoint.find(params[:metering_point_id])
    @group.metering_points.delete(@metering_point)
    redirect_to group_path(@group)
  end

  def bubbles_data
    @group = Group.find(params[:id])
    in_metering_point_data = []
    out_metering_point_data = []
    @group.metering_points.each do |metering_point|
      data_entry = []
      latest_readings = nil
      if metering_point.users.any?
        user_name = metering_point.users.collect{|user| user.profile.first_name}.join(", ")
      else
        user_name = metering_point.decorate.name
      end
      if metering_point.meter
        if metering_point.meter.smart? && metering_point.meter.online && metering_point.meter.init_reading
          latest_readings = Reading.last_two_by_metering_point_id(metering_point.id)
        elsif metering_point.meter.smart? && metering_point.meter.online && !metering_point.meter.init_reading
          #TODO: init_reading ausführen
        elsif metering_point.meter.smart? && !metering_point.meter.online && metering_point.meter.init_reading
          #TODO: show slp values?
        elsif !metering_point.meter.smart?
          #TODO: show slp values
        end
      end
      if metering_point.mode == "out"
        if !latest_readings.nil? && !latest_readings.first.nil? && !latest_readings.last.nil?
          data_entry.push(metering_point.id, latest_readings.first[:timestamp].to_i*1000, latest_readings.first[:watt_hour], latest_readings.last[:timestamp].to_i*1000, latest_readings.last[:watt_hour], user_name)
        else
          data_entry.push(metering_point.id, -1, 0, -1, 0, user_name)
        end
        out_metering_point_data.push(data_entry)
      else
        if !latest_readings.nil? && !latest_readings.first.nil? && !latest_readings.last.nil?
          data_entry.push(metering_point.id, latest_readings.first[:timestamp].to_i*1000, latest_readings.first[:watt_hour], latest_readings.last[:timestamp].to_i*1000, latest_readings.last[:watt_hour], user_name)
        else
          data_entry.push(metering_point.id, -1, 0, -1, 0, user_name)
        end
        in_metering_point_data.push(data_entry)
      end
    end
    render json: [in_metering_point_data, out_metering_point_data].to_json
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
      :metering_point_ids => []
    )
  end



end






