class ProfileResource < ApplicationResource

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
end
