class Oauth::ApplicationsController < Doorkeeper::ApplicationsController
  before_filter :authenticate_user!

  def index
    @applications = Doorkeeper::Application.all
  end


  def create
    @application = Doorkeeper::Application.new(application_params)
    authorize_action_for @application
    if @application.save
      current_user.add_role(:manager, @application)
      flash[:notice] = I18n.t(:notice, :scope => [:doorkeeper, :flash, :applications, :create])
      redirect_to oauth_application_url(@application)
    else
      render :new
    end
  end



  def show
    @application = Doorkeeper::Application.find(params[:id])
    authorize_action_for(@application)
  end


end
