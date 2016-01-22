
PublicActivity::Activity.class_eval do
  acts_as_commentable
  acts_as_votable

  has_many :badge_notifications

  scope :group_joins, lambda {
    where(:key => 'group_metering_point_membership.create')
  }

  scope :metering_point_joins, lambda {
    where(:key => 'metering_point_user_membership.create')
  }
end
