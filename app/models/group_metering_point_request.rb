class GroupMeteringPointRequest < ActiveRecord::Base
  belongs_to :sender, class_name: 'User'
  belings_to :sender_mp, class_name: 'MeteringPoint'
  belongs_to :receiver, class_name: 'Group'

  after_save :created_membership

  def accept
    update_attributes(:status  => 'accepted')
  end

  def reject
    update_attributes(:status => 'rejected')
  end


  private
    def created_membership
      if status_changed? && status == 'accepted'
        sender_mp.group = receiver
        self.delete
      elsif status_changed? && status == 'rejected'
        self.delete
      end
    end
end