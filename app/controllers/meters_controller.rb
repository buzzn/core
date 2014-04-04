class MetersController < InheritedResources::Base
  before_filter :authenticate_user!
  respond_to :html


  def index
    @meters = Meter.with_role(:manager, current_user)
    index!
  end

  def create
    @meter = Meter.new(meter_params)
    if @meter.save
      current_user.add_role :manager, @meter
    end
    create!
  end

  def edit
    @meter = Meter.friendly.find(params[:id])
    authorize_action_for(@meter)
    edit!
  end

  def update
    @meter = Meter.friendly.find(params[:id])
    authorize_action_for(@meter)
    update!
  end

  def show
    @meter = Meter.friendly.find(params[:id])
    authorize_action_for(@meter)
    show!
  end




  def permitted_params
    params.permit(:meter => [:contract_id, :name, :uid])
  end


private
  def meter_params
    params.require(:meter).permit(:address, :api_type, :uid, :public)
  end

end
