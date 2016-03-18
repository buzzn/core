class FriendshipRequest < ActiveRecord::Base
  include PublicActivity::Model
  tracked owner: :sender, recipient: :receiver

  belongs_to :sender, class_name: 'User'
  belongs_to :receiver, class_name: 'User'

  after_save :created_friendship, :unless => :skip_callbacks

  cattr_accessor :skip_callbacks


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
        sender.friends << receiver if !sender.friends.include?(receiver)
        delete_self_and_similar
      elsif status == 'rejected'
        delete_self_and_similar
      end
    end

    def delete_self_and_similar
      self.delete
      similar_requests = FriendshipRequest.where(sender_id: receiver.id).where(receiver_id: sender.id)
      similar_requests.each do |request|
        request.delete
      end
    end
end
