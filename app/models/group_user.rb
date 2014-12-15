class GroupUser < ActiveRecord::Base
  belongs_to :group
  belongs_to :user

  default_scope -> { order(:created_at => :desc) }
end
