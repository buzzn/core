ActiveAdmin.register Register::Base do

  menu :parent => "System", :label => "Register"

  index do
    id_column
    column :mode
    column :name
    column :label
    column :obis
    column :group
    actions
  end


end
