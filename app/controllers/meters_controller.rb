class MetersController < InheritedResources::Base
  respond_to :html


  def permitted_params
    params.permit(:meter => [:name, :uid, :private])
  end

end
