class BadgeNotification < ActiveRecord::Base
  belongs_to :user
  belongs_to :activity, class_name: PublicActivity::Activity

  scope :unread, -> { where(read_by_user: false) }
  scope :read, -> { where(read_by_user: true) }
end
