class LocationsController < InheritedResources::Base
  before_filter :authenticate_user!
  respond_to :html, :js, :json


  def show
    location    = Location.find(params[:id])
    @metering_points = location.metering_point.subtree.arrange
    respond_to do |format|
      format.html { @location = location.decorate
                    @residents  = @location.users
                    @devices    = @location.devices
                    if @location.metering_point
                      gon.push({ registers: Register.where("metering_point_id = :root_id OR metering_point_id IN (:children_ids)", {root_id: location.metering_point.id, children_ids: location.metering_point.child_ids }).collect(&:day_to_hours),
                                 end_of_day: Time.now.end_of_day.to_i * 1000
                      })
                    end
      }
      format.json{ @location = location
                    render :json =>  MeteringPoint.json_tree(@metering_points)
      }
    end
    gon.push({ location_id: @location.id })
  end

  def new
    @location         = Location.new
    @location.address = Address.new
    new!
  end

  def create
    create! do |success, failure|
      current_user.add_role :manager, @location
      @location = LocationDecorator.new(@location)
      success.js { @location }
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
      address_attributes: [:id, :street_name, :street_number, :city, :state, :zip, :country, :_destroy]
    ]
  end



end

