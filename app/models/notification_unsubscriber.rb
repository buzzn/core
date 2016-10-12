class NotificationUnsubscriber < ActiveRecord::Base
  belongs_to :user
  belongs_to :trackable, :polymorphic => true

  scope :by_key, lambda {|key|
    where(notification_key: key)
  }

  scope :by_resource, lambda {|resource|
    where(trackable: resource)
  }

  scope :by_user, lambda {|user|
    where(user: user)
  }

  scope :within_users, lambda {|user_ids|
    if user_ids.is_a? User::ActiveRecord_Relation
      user_ids = user_ids.select(:id)
    end
    where('user_id IN (?)', user_ids)
  }

end
