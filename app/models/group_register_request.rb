class GroupRegisterRequest < ActiveRecord::Base
  #include PublicActivity::Model
  #tracked

  belongs_to :user
  belongs_to :register, class_name: Register::Base
  belongs_to :group, class_name: Group::Base, foreign_key: :group_id

  after_save :created_membership, :unless => :skip_callbacks

  cattr_accessor :skip_callbacks

  scope :requests,    -> { where(mode: 'request') }
  scope :invitations, -> { where(mode: 'invitation') }

  def accept
    GroupRegisterRequest.skip_callbacks = true
    update_attributes(:status  => 'accepted')
    GroupRegisterRequest.skip_callbacks = false
  end

  def reject
    GroupRegisterRequest.skip_callbacks = true
    update_attributes(:status => 'rejected')
    GroupRegisterRequest.skip_callbacks = false
  end


  private
    def created_membership
      if status == 'accepted'
        register.group = group
        group.registers << register
        group.save
        #group.calculate_closeness
        self.delete
      elsif status == 'rejected'
        self.delete
      end
    end
end
