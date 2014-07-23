class Friendship < ActiveRecord::Base
  belongs_to :user
  belongs_to :friend, class_name: 'User'

  #scope :send_by_user, ->(user) { where(sender: user) }

end
