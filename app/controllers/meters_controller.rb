class MetersController < InheritedResources::Base
  before_filter :authenticate_user!
  respond_to :html


  def index
    @meters = Meter.with_role(:manager, current_user)
    index!
  end

  def new
    @meter = Meter.new
    @meter.address = Address.new
    new!
  end


protected
  def permitted_params
    params.permit(:meter => init_permitted_params)
  end

private
  def meter_params
    params.require(:meter).permit(init_permitted_params)
  end

  def init_permitted_params
    [
      :name,
      :uid,
      external_contracts_attributes: [:id, :mode, :customer_number, :contract_number, :_destroy]
    ]
  end



end
