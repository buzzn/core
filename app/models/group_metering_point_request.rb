class GroupMeteringPointRequest < ActiveRecord::Base
  belongs_to :user
  belongs_to :metering_point
  belongs_to :group

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
        metering_point.group = group
        group.metering_points << metering_point
        self.delete
      elsif status_changed? && status == 'rejected'
        self.delete
      end
    end
end