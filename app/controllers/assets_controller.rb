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
    edit! do |format|
      @asset = AssetDecorator.new(@asset)
    end
  end

  def permitted_params
    params.permit(:asset => [:image, :description, :assetable_id, :assetable_type])
  end

end