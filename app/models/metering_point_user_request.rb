class MeteringPointUserRequest < ActiveRecord::Base
  #include PublicActivity::Model
  #tracked owner: Proc.new{ |controller, model| controller && controller.current_user }

  belongs_to :user
  belongs_to :metering_point

  after_save :created_membership, :unless => :skip_callbacks

  cattr_accessor :skip_callbacks

  scope :requests,    -> { where(mode: 'request') }
  scope :invitations, -> { where(mode: 'invitation') }

  def accept
    MeteringPointUserRequest.skip_callbacks = true
    update_attributes(:status  => 'accepted')
    MeteringPointUserRequest.skip_callbacks = false
  end

  def reject
    MeteringPointUserRequest.skip_callbacks = true
    update_attributes(:status => 'rejected')
    MeteringPointUserRequest.skip_callbacks = false
  end


  private
    def created_membership
      if status == 'accepted'
        user.add_role(:member, metering_point)
        self.delete
      elsif status == 'rejected'
        self.delete
      end
    end
end
