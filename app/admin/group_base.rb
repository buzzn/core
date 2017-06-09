ActiveAdmin.register Group::Base do

  menu :label => "Group"

  index do
    id_column
    column :name
    column :type
    # column :group_owner do |group|
    #   group.owner
    # end
    actions
  end

end
