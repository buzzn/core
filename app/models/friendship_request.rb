class FriendshipRequest < ActiveRecord::Base
  include PublicActivity::Model
  tracked

  belongs_to :sender, class_name: 'User'
  belongs_to :receiver, class_name: 'User'

  after_save :created_friendship, :unless => :skip_callbacks

  cattr_accessor :skip_callbacks

  default_scope -> { order(:created_at => :desc) }

  def accept
    FriendshipRequest.skip_callbacks = true
    update_attributes(:status  => 'accepted')
    FriendshipRequest.skip_callbacks = false
  end

  def reject
    FriendshipRequest.skip_callbacks = true
    update_attributes(:status => 'rejected')
    FriendshipRequest.skip_callbacks = false
  end


  private
    def created_friendship
      if status == 'accepted'
        sender.friends << receiver
        self.delete
      elsif status == 'rejected'
        self.delete
      end
    end
end
