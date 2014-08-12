class Asset < ActiveRecord::Base

  belongs_to :assetable, polymorphic: true

  mount_uploader :image, PictureUploader

  default_scope -> { order('created_at ASC') }


  # TODO make reverse polymorphic nicer
  def device
    Device.find(self.assetable_id)
  end


end