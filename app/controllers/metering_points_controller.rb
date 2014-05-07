class MeteringPointsController < InheritedResources::Base
  before_filter :authenticate_user!
  respond_to :html, :js



  def new_down
    @metering_point = MeteringPoint.new(mode: 'down_metering')
    new!
  end
  authority_actions :new_down => 'create'

  def edit_down
    @metering_point = MeteringPoint.find(params[:id])
    authorize_action_for(@metering_point)
    edit!
  end
  authority_actions :edit_down => 'update'




  def new_up
    @metering_point = MeteringPoint.new(mode: 'up_metering')
    authorize_action_for Location.find(params[:location_id])
    new!
  end
  authority_actions :new_up => 'create'

  def edit_up
    @metering_point = MeteringPoint.find(params[:id])
    authorize_action_for(@metering_point)
    edit!
  end
  authority_actions :edit_up => 'update'




  def new_up_down
    @metering_point = MeteringPoint.new(mode: 'up_down_metering')
    new!
  end
  authority_actions :new_up_down => 'create'

  def edit_up_down
    @metering_point = MeteringPoint.find(params[:id])
    authorize_action_for(@metering_point)
    edit!
  end
  authority_actions :edit_up_down => 'update'




  def new_diff
    @metering_point = MeteringPoint.new(mode: 'diff_metering')
    new!
  end
  authority_actions :new_diff => 'create'

  def edit_diff
    @metering_point = MeteringPoint.find(params[:id])
    authorize_action_for(@metering_point)
    edit!
  end
  authority_actions :edit_diff => 'update'


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
