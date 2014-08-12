class GroupMeteringPointRequest < ActiveRecord::Base
  include PublicActivity::Model
  tracked

  belongs_to :user
  belongs_to :metering_point
  belongs_to :group

  after_save :created_membership, :unless => :skip_callbacks

  cattr_accessor :skip_callbacks

  def accept
    GroupMeteringPointRequest.skip_callbacks = true
    update_attributes(:status  => 'accepted')
    GroupMeteringPointRequest.skip_callbacks = false
  end

  def reject
    GroupMeteringPointRequest.skip_callbacks = true
    update_attributes(:status => 'rejected')
    GroupMeteringPointRequest.skip_callbacks = false
  end


  private
    def created_membership
      if status == 'accepted'
        metering_point.group = group
        group.metering_points << metering_point
        self.delete
      elsif status == 'rejected'
        self.delete
      end
    end
end