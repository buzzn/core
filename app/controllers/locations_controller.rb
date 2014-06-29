class LocationsController < InheritedResources::Base
  before_filter :authenticate_user!
  respond_to :html, :js


  def show
    @location   = Location.find(params[:id]).decorate
    @residents  = User.all.decorate
    @devices    = Device.all.decorate
    show!
  end

  def new
    @location         = Location.new
    @location.address = Address.new
    new!
  end

  def create
    create! do |format|
      current_user.add_role :manager, @location
      @location = LocationDecorator.new(@location)
    end
  end

  def edit
    edit! do |format|
      @location = LocationDecorator.new(@location)
    end
  end


  def update
    update! do |format|
      @location = LocationDecorator.new(@location)
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
      :name,
      :image,
      address_attributes: [:id, :street_name, :street_number, :city, :state, :zip, :country, :_destroy]
    ]
  end



end

