class Contract < ActiveRecord::Base
  resourcify
  include Authority::Abilities
  has_paper_trail

  attr_encrypted :password, :charset => 'UTF-8', :key => 'This is a salt for your soup'

  monetize :price_cents

  belongs_to :contracting_party
  belongs_to :organization
  belongs_to :metering_point
  belongs_to :group

  validates :organization, presence: true
  validates :username, presence: true, if: :login_required?
  validates :password, presence: true, if: :login_required?

  scope :running,                   -> { where(running: :true) }
  scope :metering_point_operators,  -> { where(mode: 'metering_point_operator_contract') }
  scope :electricity_suppliers,     -> { where(mode: 'electricity_supplier_contract') }
  scope :servicings,                -> { where(mode: 'servicing_contract') }



  after_save :validates_credentials_job


  has_one :address, as: :addressable
  accepts_nested_attributes_for :address, :reject_if => :all_blank

  has_one :bank_account, as: :bank_accountable
  accepts_nested_attributes_for :bank_account, :reject_if => :all_blank




  def name
    metering_point.name if metering_point
  end

  def self.modes
    %w{
      sss
    }
  end

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










