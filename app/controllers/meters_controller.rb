class MetersController < InheritedResources::Base
  before_filter :authenticate_user!
  authorize_actions_for Meter
  respond_to :html


  def index
    @meters = Meter.with_role(:manager, current_user)
    index!
  end

  def permitted_params
    params.permit(:meter => [:address, :brand, :uid, :public])
  end

end
