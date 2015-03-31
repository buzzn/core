class ProfileSerializer < ActiveModel::Serializer
  attributes :id, :slug, :user_name, :first_name, :last_name, :md_img

  def md_img
    object.image.md.url
  end

end
