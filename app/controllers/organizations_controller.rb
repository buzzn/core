class OrganizationsController < InheritedResources::Base
  before_filter :authenticate_user!
  respond_to :html, :js

  def show
    @organization = Organization.find(params[:id]).decorate
    authorize_action_for(@organization)
    show!
  end


  def new
    @organization = Organization.new
    @organization.address = Address.new
    authorize_action_for(@organization)
    new!
  end
  authority_actions :new => 'create'

  def edit
    @organization = Organization.find(params[:id])
    authorize_action_for(@organization)
    edit!
  end
  authority_actions :edit => 'update'

  def update
    update! do |success, failure|
      @organization = OrganizationDecorator.new(@organization)
      success.js { @organization }
      failure.js { render :edit }
    end
  end

  def create
    create! do |success, failure|
      @organization = OrganizationDecorator.new(@organization)
      success.js { @organization }
      failure.js { render :new }
    end
  end


protected
  def permitted_params
    params.permit(:organization => init_permitted_params)
  end

private
  def organization_params
    params.require(:organization).permit(init_permitted_params)
  end

  def init_permitted_params
    [
      :id,
      :slug,
      :name,
      :email,
      :edifactemail,
      :phone,
      :fax,
      :description,
      :website,
      :mode,
      :contracting_party,
      address_attributes: [:id, :street_name, :street_number, :city, :state, :zip, :country, :time_zone, :_destroy]
    ]
  end
end