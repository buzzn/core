ActiveAdmin.register User do
  permit_params :email, :password, :password_confirmation

  index do
    id_column
    column :email
    column :first_name do |user|
      user.profile.first_name
    end
    column :last_name do |user|
      user.profile.last_name
    end

    column "address" do |user|
      if user.address
        s = []
        s << user.address.city if user.address.city
        s << user.address.country if user.address.country
        s.join(', ')
      end
    end


    column :current_sign_in_at
    column :sign_in_count
    column :created_at
    actions
  end

  filter :email
  filter :current_sign_in_at
  filter :sign_in_count
  filter :created_at

  form do |f|
    f.inputs "Admin Details" do
      f.input :email
      f.input :password
      f.input :password_confirmation
    end
    f.actions
  end

end
