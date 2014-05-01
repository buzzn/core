class MeteringPointsController < InheritedResources::Base
  before_filter :authenticate_user!
  respond_to :html, :js



  def new_down
    @metering_point = MeteringPoint.new(mode: 'down_metering')
    new!
  end
  
  def edit_down
    @metering_point = MeteringPoint.find(params[:id])
    edit!
  end



  def new_up
    @metering_point = MeteringPoint.new(mode: 'up_metering')
    new!
  end

  def edit_up
    @metering_point = MeteringPoint.find(params[:id])
    edit!
  end



  def new_up_down
    @metering_point = MeteringPoint.new(mode: 'up_down_metering')
    new!
  end

  def edit_up_down
    @metering_point = MeteringPoint.find(params[:id])
    edit!
  end



  def new_diff
    @metering_point = MeteringPoint.new(mode: 'diff_metering')
    new!
  end

  def edit_diff
    @metering_point = MeteringPoint.find(params[:id])
    edit!
  end



  def update
    update! do |format|
      @metering_point = MeteringPointDecorator.new(@metering_point)
    end
  end

  def create
    create! do |format|
      @metering_point = MeteringPointDecorator.new(@metering_point)
    end
  end



protected
  def permitted_params
    params.permit(:metering_point => init_permitted_params)
  end

private
  def meter_params
    params.require(:metering_point).permit(init_permitted_params)
  end

  def init_permitted_params
    [
      :location_id,
      :uid,
      :mode,
      :address_addition
    ]
  end



end
