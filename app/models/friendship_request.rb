class FriendshipRequest < ActiveRecord::Base
  belongs_to :sender, class_name: 'User'
  belongs_to :receiver, class_name: 'User'

  after_save :created_friendship

  def accept
    update_attributes(:status  => 'accepted')
  end


  private
    def created_friendship
      if status_changed? && status == 'accepted'
        sender.friends << receiver
        self.delete
      end
    end

end
