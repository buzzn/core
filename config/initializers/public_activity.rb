
PublicActivity::Activity.class_eval do
  acts_as_commentable
  acts_as_votable

  scope :group_joins, lambda {
    where(:key => 'group_metering_point_membership.create')
  }
end
