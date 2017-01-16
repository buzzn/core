class ProfileResource < JSONAPI::Resource

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
              :readable,
              :website,
              :facebook,
              :twitter,
              :xing,
              :linkedin

  def md_img
    @model.image.md.url
  end

end
