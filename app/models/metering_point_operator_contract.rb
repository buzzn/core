class MeteringPointOperatorContract < ActiveRecord::Base
  attr_encrypted :password, :charset => 'UTF-8', :key => 'This is a salt for your soup'

  belongs_to :organization
  belongs_to :metering_point
  belongs_to :group

  validates :organization, presence: true
  validates :username, presence: true, if: :login_required?
  validates :password, presence: true, if: :login_required?

  scope :running, -> { where(running: :true) }

  after_save :validates_credentials_job

  default_scope -> { order(:created_at => :desc) }

  def login_required?
    if self.organization.nil?
      false
    else
      self.organization.slug == 'discovergy'
    end
  end



private

  def validates_credentials_job
    Sidekiq::Client.push({
     'class' => ValidatesCredentialsWorker,
     'queue' => :low,
     'args' => [ 'MeteringPointOperatorContract', self.id ]
    })
  end


end
