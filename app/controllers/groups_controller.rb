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
    @out_devices                    = @out_metering_points.collect(&:devices)
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
      latest_power = nil
      virtual = metering_point.virtual
      metering_point_name = metering_point.decorate.name
      if metering_point.users.any?
        metering_point_name = metering_point_name + " (" + metering_point.users.collect{|user| user.profile.first_name}.join(", ") + ")"
        if metering_point.users.include?(current_user)
          own_metering_point = true
        else
          own_metering_point = false
          #user_name = metering_point.users.collect{|user| user.profile.first_name}.join(", ")
        end
      else
        own_metering_point = false
      end
      if metering_point.meter
        if metering_point.meter.smart? && metering_point.meter.online && metering_point.meter.init_reading
          latest_power = metering_point.last_power
        elsif metering_point.meter.smart? && metering_point.meter.online && !metering_point.meter.init_reading
          #TODO: init_reading ausführen
        elsif metering_point.meter.smart? && !metering_point.meter.online && metering_point.meter.init_reading
          #TODO: show slp values?
        elsif !metering_point.meter.smart?
          #TODO: show slp values
        end
      else
        if metering_point.virtual #&& metering_point.meter.smart? && metering_point.meter.online && metering_point.meter.init_reading
          latest_power = metering_point.last_power
        end
      end
      readable = user_signed_in? ? metering_point.readable_by?(current_user) : false
      if !readable
        metering_point_name = "anonym"
      end
      if metering_point.mode == "out"
        if !latest_power.nil?
          data_entry = {:metering_point_id => metering_point.id, :latest_power => latest_power[:power], :name => metering_point_name, :virtual => virtual, :own_metering_point => own_metering_point, :readable => true}
          #data_entry.push(metering_point.id, latest_power, user_name, virtual)
        else
          data_entry = {:metering_point_id => metering_point.id, :latest_power => 0, :name => metering_point_name, :virtual => virtual, :own_metering_point => own_metering_point, :readable => true}
          #data_entry.push(metering_point.id, 0, user_name, virtual)
        end
        out_metering_point_data.push(data_entry)
      else
        if !latest_power.nil?
          data_entry = {:metering_point_id => metering_point.id, :latest_power => latest_power[:power], :name => metering_point_name, :virtual => virtual, :own_metering_point => own_metering_point, :readable => readable}
          #data_entry.push(metering_point.id, latest_power, user_name, virtual)
        else
          data_entry = {:metering_point_id => metering_point.id, :latest_power => 0, :name => metering_point_name, :virtual => virtual, :own_metering_point => own_metering_point, :readable => readable}
          #data_entry.push(metering_point.id, 0, user_name, virtual)
        end
        in_metering_point_data.push(data_entry)
      end
    end
    out_data = { :name => "Gesamterzeugung", :children => out_metering_point_data}
    result = {:in => in_metering_point_data, :out => out_data}
    render json: result.to_json
  end

  def chart
    @group = Group.find(params[:id])
    @data_in = []
    @data_out = []
    @metering_points_in = []
    @metering_points_out = []

    @group.metering_points.each do |metering_point|
      if !metering_point.smart?
        next
      end

      if metering_point.virtual
        operands_plus = FormulaPart.where(metering_point_id: metering_point.id).where(operator: "+").collect(&:operand)
        operands_plus.each do |metering_point_plus|
          if metering_point_plus.mode == "in"
            @metering_points_in << metering_point_plus.id
          else
            @metering_points_out << metering_point_plus.id
          end
        end

        operands_minus = FormulaPart.where(metering_point_id: metering_point.id).where(operator: "-").collect(&:operand)
        operands_minus.each do |metering_point_minus|
          if metering_point_minus.mode == "in"
            @metering_points_in << metering_point_minus.id
          else
            @metering_points_out << metering_point_minus.id
          end
        end
      else
        if metering_point.mode == "in"
          @metering_points_in << metering_point.id
        else
          @metering_points_out << metering_point.id
        end
      end
    end

    if params[:resolution] == "hour_to_minutes"
      resolution_format = :hour_to_minutes
    elsif params[:resolution] == nil || params[:resolution] == "day_to_minutes"
      resolution_format = :day_to_minutes
    elsif params[:resolution] == "month_to_days"
      resolution_format = :month_to_days
    elsif params[:resolution] == "year_to_months"
      resolution_format = :year_to_months
    end

    if params[:containing_timestamp] == nil
      containing_timestamp = Time.now.to_i * 1000
    else
      containing_timestamp = params[:containing_timestamp]
    end

    result_in = @group.convert_to_array_build_timestamp(Reading.aggregate(resolution_format, @metering_points_in, containing_timestamp), resolution_format, containing_timestamp)
    result_out = @group.convert_to_array_build_timestamp(Reading.aggregate(resolution_format, @metering_points_out, containing_timestamp), resolution_format, containing_timestamp)

    render json: [ { :name => t('total_consumption'), :data => result_in}, { :name => t('total_production'), :data => result_out} ].to_json
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






