ActiveAdmin.register Document do

  menu :parent => "System", :label => "Document"

  index do
    id_column
    column :path
    column :encryption_details
    column :created_at
    column :updated_at
    actions
  end

end
