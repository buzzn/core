class MetersController < InheritedResources::Base
  respond_to :html

  # def create
  #   @meter = Meter.new(params[:meter])
  #   authorize(@meter)
  #   create!
  # end



  def authorize(record)
    raise NotAuthorizedError unless policy(record).public_send(params[:action] + "?")
  end

  def permitted_params
    params.permit(:meter => [:name, :uid, :private])
  end
end
