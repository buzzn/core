class NotificationUnsubscriber < ActiveRecord::Base
  belongs_to :user
  belongs_to :trackable, :polymorphic => true

  scope :by_key, lambda {|key|
    where("notification_key in (?)", [key])
  }

  scope :by_resource, lambda {|resource|
    where(trackable: resource)
  }

  scope :by_user, lambda {|user|
    where(user: user)
  }
end
