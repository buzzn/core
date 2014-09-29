class AssetsController < InheritedResources::Base
  respond_to :html, :js

  def show
    @asset = Asset.find(params[:id])
  end

  def create
    create! do |success, failure|
      @asset = AssetDecorator.new(@asset)
      success.js { @asset }
      failure.js { render :new }
    end
  end

  def update
    update! do |success, failure|
      @asset = AssetDecorator.new(@asset)
      success.js { @asset }
      failure.js { render :edit }
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