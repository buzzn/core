class ProfileResource < ApplicationResource

  attributes  :slug,
              :user_name,
              :first_name,
              :last_name,
              :about_me,
              :md_img,
              :readable, :updateable, :deletable

end
