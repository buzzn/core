class Asset < ActiveRecord::Base

  acts_as_list

  belongs_to :assetable, polymorphic: true

  mount_uploader :image, PictureUploader

  default_scope -> { order('position ASC') }

  validates :image, presence: true


  # TODO make reverse polymorphic nicer
  def device
    Device.find(self.assetable_id) if self.assetable_type == "Device"
  end

  def group
    Group.find(self.assetable_id) if self.assetable_type == "Group"
  end

  def organization
    Organization.find(self.assetable_id) if self.assetable_type == "Organization"
  end



end