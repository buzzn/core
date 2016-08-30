class Oauth::ApplicationsController < Doorkeeper::ApplicationsController
  before_filter :authenticate_user!

  # used for authority to make it possible to deal with logged out users
  def current_or_null_user
    if current_user == nil
      User.new
    else
      current_user
    end
  end

  def index
    if current_user.has_role?(:admin)
      @applications = Doorkeeper::Application.all
    else
      @applications = current_user.oauth_applications
    end
  end

  # only needed if each application must have some owner
  def create
    @application = Doorkeeper::Application.new(application_params)
    @application.owner = current_user if Doorkeeper.configuration.confirm_application_owner?
    if @application.save
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


  def update
    @application = Doorkeeper::Application.find(params[:id])
    authorize_action_for(@application)
    if @application.update_attributes(application_params)
      redirect_to oauth_application_url(@application)
    else
      render :edit
    end
  end

  def destroy
    @application = Doorkeeper::Application.find(params[:id])
    authorize_action_for(@application)
    @application.destroy
    redirect_to oauth_applications_path
  end


end
