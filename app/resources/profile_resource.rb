class ProfileResource < ApplicationResource

  attributes  :slug,
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
end
