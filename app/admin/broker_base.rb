ActiveAdmin.register Broker::Base do

  index do
    id_column
    column :mode
    column :type
    column :external_id
    column :resource_type
    column :resource_id
    actions
  end

end
