class Area < ActiveRecord::Base
  belongs_to :group, class_name: Group::Base, foreign_key: :group_id
end
