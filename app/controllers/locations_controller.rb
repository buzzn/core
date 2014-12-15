class LocationsController < InheritedResources::Base
  before_filter :authenticate_user!
  respond_to :html, :js, :json


  def show
    location    = Location.find(params[:id])
    if location.metering_point
      @metering_points = location.metering_point.subtree
    else
      @metering_points = location.metering_point #nil if location was just created
    end
    respond_to do |format|
      format.html {
        @location   = location.decorate
        @residents  = @location.users
        @devices    = @location.devices
        authorize_action_for(@location)
      }

      format.json{
        @location = location
        authorize_action_for(@location)
        render :json =>  MeteringPoint.json_tree(@location.metering_point.subtree.arrange)
      }
    end
    if @metering_points
      gon.push({ register_ids: @metering_points.collect(&:registers).flatten.collect(&:id),
                  pusher_host: Rails.application.secrets.pusher_host,
                  pusher_key: Rails.application.secrets.pusher_key })
    else
      gon.push({ register_ids: [] })
    end
  end
  authority_actions :show => 'read'

  def new
    @location         = Location.new
    @location.address = Address.new
    new!
  end

  def create
    create! do |success, failure|
      current_user.add_role :manager, @location
      @location = LocationDecorator.new(@location)
      success.js {
        flash[:notice] = t('location_created_successfully')
        @location
      }
      failure.js { render :new }
    end
  end

  def edit
    edit! do |format|
      @location = LocationDecorator.new(@location)
    end
  end


  def update
    update! do |success, failure|
      @location = LocationDecorator.new(@location)
      success.js { @location }
      failure.js { render :edit }
    end
  end

  def destroy
    destroy! do |failure|
      failure.js {
        @location = LocationDecorator.new(@location)
        flash[:error] = t('cannot_delete_location_while_metering_point_exists')
        @location
      }
    end
  end


protected
  def permitted_params
    params.permit(:location => init_permitted_params)
  end

private
  def location_params
    params.require(:location).permit(init_permitted_params)
  end

  def init_permitted_params
    [
      address_attributes: [:id, :street_name, :street_number, :city, :state, :zip, :country, :time_zone, :_destroy]
    ]
  end



end

