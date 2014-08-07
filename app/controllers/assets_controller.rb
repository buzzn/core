class AssetsController < InheritedResources::Base
  respond_to :html, :js

  def show
    @asset = Asset.find(params[:id])
    @device = Device.find(params[:id])
  end

  def create
    create! do |format|
      @asset = AssetDecorator.new(@asset)
    end
  end

  def edit
    @asset = Asset.find(params[:id]).decorate
    edit!
  end

  def permitted_params
    params.permit(:asset => [:image, :description])
  end

end