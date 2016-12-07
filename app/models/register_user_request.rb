class RegisterUserRequest < ActiveRecord::Base
  #include PublicActivity::Model
  #tracked owner: Proc.new{ |controller, model| controller && controller.current_user }

  belongs_to :user
  belongs_to :register, class_name: Register::Base

  after_save :created_membership, :unless => :skip_callbacks

  cattr_accessor :skip_callbacks

  scope :requests,    -> { where(mode: 'request') }
  scope :invitations, -> { where(mode: 'invitation') }

  def accept
    RegisterUserRequest.skip_callbacks = true
    update_attributes(:status  => 'accepted')
    RegisterUserRequest.skip_callbacks = false
  end

  def reject
    RegisterUserRequest.skip_callbacks = true
    update_attributes(:status => 'rejected')
    RegisterUserRequest.skip_callbacks = false
  end


  private
    def created_membership
      if status == 'accepted'
        self.delete
      elsif status == 'rejected'
        self.delete
      end
    end
end
