class Asset < ActiveRecord::Base
  mount_uploader :image, PictureUploader



end