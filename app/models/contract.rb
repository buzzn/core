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
  #validates :price_cents, presence: true, :numericality => { :only_integer => false, :greater_than_or_equal_to => 0 }
  validate :resource_cannot_have_same_contracts

  scope :running,                   -> { where(running: :true) }
  scope :metering_point_operators,  -> { where(mode: 'metering_point_operator_contract') }
  scope :electricity_suppliers,     -> { where(mode: 'electricity_supplier_contract') }
  scope :electricity_purchases,     -> { where(mode: 'electricity_purchase_contract') }
  scope :servicings,                -> { where(mode: 'servicing_contract') }


  after_save :validates_credentials

  has_one :address, as: :addressable
  accepts_nested_attributes_for :address, :reject_if => :all_blank

  has_one :bank_account, as: :bank_accountable
  accepts_nested_attributes_for :bank_account, :reject_if => :all_blank




  def name
    "#{organization.name} #{tariff}"
  end

  # def self.modes
  #   %w{
  #     electricity_supplier_contract
  #     electricity_purchase_contract
  #     metering_point_operator_contract
  #     servicing_contract
  #   }.map(&:to_sym)
  # end

  def self.modes
    %w{
      metering_point_operator_contract
    }.map(&:to_sym)
  end

  def login_required?
    if self.organization
      self.organization.slug == 'discovergy' ||  self.organization.slug == 'amperix'
    else
      false
    end
  end

  def resource_cannot_have_same_contracts
    if metering_point && metering_point.contracts.any?
      #available_contracts = Contract.where(metering_point: self.metering_point).where(mode: self.mode)
      available_contracts = metering_point.contracts.collect{|c| c if c.mode == self.mode}.compact
      if available_contracts.any? && available_contracts.first != self
        errors.add(:mode, I18n.t("already_exists"))
      end
    elsif group && group.contracts.any?
      #available_contracts = Contract.where(group: self.group).where(mode: self.mode)
      available_contracts = group.contracts.collect{|c| c if c.mode == self.mode}.compact
      if available_contracts.any? && available_contracts.first != self
        errors.add(:mode, I18n.t("already_exists"))
      end
    end
  end

  def send_notification_credentials(valid)
    contract = self
    if contract && contract.contracting_party
      user = contract.contracting_party.user
      if valid
        user.send_notification("success", I18n.t("valid_credentials"), I18n.t("your_credentials_have_been_checked_and_are_valid", contract: contract.mode))
      else
        user.send_notification("danger", I18n.t("invalid_credentials"), I18n.t("your_credentials_have_been_checked_and_are_invalid", contract: contract.mode))
      end
    end
  end



private

  def validates_credentials
    if self.mode == 'metering_point_operator_contract'
      if self.organization.slug == 'discovergy' || self.organization.slug == 'buzzn-metering'
        api_call = Discovergy.new(self.username, self.password).meters
        if api_call['status'] == 'ok'
          self.update_columns(valid_credentials: true)
          #self.send_notification_credentials(true)
          if self.group
            self.group.metering_points.each do |metering_point|
              metering_point.meter.save if metering_point.meter
            end
          end
          if self.metering_point && self.metering_point.meter
            self.metering_point.meter.save
          end
        end
      elsif self.organization.slug == 'amperix' # no automated group check implemented yet
        amperix = Amperix.new(self.username, self.password)
        api_call = amperix.get_ive
        if api_call != ""
          self.update_columns(valid_credentials: true)
        end
      else
        self.update_columns(valid_credentials: false)
      end
    end
  end
end










