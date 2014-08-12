class Asset < ActiveRecord::Base

  belongs_to :assetable, polymorphic: true

  has_one :device

  mount_uploader :image, PictureUploader

  default_scope -> { order('created_at ASC') }

end