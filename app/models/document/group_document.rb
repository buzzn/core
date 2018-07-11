class GroupDocument < ActiveRecord::Base
  belongs_to :group
  belongs_to :document
end
