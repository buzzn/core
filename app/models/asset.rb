class Asset < ActiveRecord::Base

  belongs_to :assetable, polymorphic: true

  mount_uploader :image, PictureUploader

  default_scope -> { order('created_at ASC') }

  validates :image, presence: true


  # TODO make reverse polymorphic nicer
  def device
    Device.find(self.assetable_id) if self.assetable_type == "Device"
  end

  def group
    Group.find(self.assetable_id) if self.assetable_type == "Group"
  end

  def location
    Location.find(self.assetable_id) if self.assetable_type == "Location"
  end



end