PublicActivity::Activity.class_eval do
  acts_as_commentable
  acts_as_votable

  has_many :badge_notifications

  scope :group_joins, lambda {
    where(:key => 'group_register_membership.create')
  }

  scope :register_joins, lambda {
    where(:key => 'register_user_membership.create')
  }

  after_commit :notify_users, on: :create

  def notify_users
    Sidekiq::Client.push({
     'class' => NotificationCreationWorker,
     'queue' => :default,
     'args' => [
                self.id
               ]
    })
  end

end





