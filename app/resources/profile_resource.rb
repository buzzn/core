class ProfileSerializer < ActiveModel::Serializer

  attributes  :slug,
              :email,
              :user_name,
              :title,
              :first_name,
              :last_name,
              :gender,
              :phone,
              :about_me,
              :md_img,
              :readable

  def md_img
    object.image.md.url
  end

end
ProfileResource = ProfileSerializer
