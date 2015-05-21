class Contract < ActiveRecord::Base
  resourcify
  include Authority::Abilities
  has_paper_trail

  attr_encrypted :password, :charset => 'UTF-8', :key => Rails.application.secrets.attr_encrypted_key

  monetize :price_cents

  belongs_to :contracting_party
  belongs_to :organization
  belongs_to :metering_point
  belongs_to :group

  validates :mode, presence: true
  #validates :organization, presence: true
  # validates :username, presence: true, if: :login_required?
  # validates :password, presence: true, if: :login_required?
  validates :price_cents, presence: true, :numericality => { :only_integer => true, :greater_than_or_equal_to => 0 }
  validate :resource_cannot_have_same_contracts

  scope :running,                   -> { where(running: :true) }
  scope :metering_point_operators,  -> { where(mode: 'metering_point_operator_contract') }
  scope :electricity_suppliers,     -> { where(mode: 'electricity_supplier_contract') }
  scope :electricity_purchases,     -> { where(mode: 'electricity_purchase_contract') }
  scope :servicings,                -> { where(mode: 'servicing_contract') }




  after_save :validates_credentials_job


  has_one :address, as: :addressable
  accepts_nested_attributes_for :address, :reject_if => :all_blank

  has_one :bank_account, as: :bank_accountable
  accepts_nested_attributes_for :bank_account, :reject_if => :all_blank




  def name
    "#{organization.name} #{tariff}"
  end

  def self.modes
    %w{
      electricity_supplier_contract
      electricity_purchase_contract
      metering_point_operator_contract
      servicing_contract
    }.map(&:to_sym)
  end

  def login_required?
    if self.organization
      self.organization.slug == 'discovergy'
    else
      false
    end
  end

  def resource_cannot_have_same_contracts
    if metering_point && metering_point.contracts.any?
      #available_contracts = Contract.where(metering_point: self.metering_point).where(mode: self.mode)
      available_contracts = metering_point.contracts.collect{|c| c if c.mode == self.mode}
      if available_contracts.any? && available_contracts.first != self
        errors.add(:mode, "already exists")
      end
    elsif group && group.contracts.any?
      #available_contracts = Contract.where(group: self.group).where(mode: self.mode)
      available_contracts = group.contracts.collect{|c| c if c.mode == self.mode}
      if available_contracts.any? && available_contracts.first != self
        errors.add(:mode, "already exists")
      end
    end
  end



private

  def validates_credentials_job
    Sidekiq::Client.push({
     'class' => ValidatesCredentialsWorker,
     'queue' => :low,
     'args' => [ self.id ]
    })
  end


end










