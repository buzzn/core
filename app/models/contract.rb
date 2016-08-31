class Contract < ActiveRecord::Base
  resourcify
  include Authority::Abilities
  include Filterable
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

  scope :readable_by,               -> (user) do
    if user
      contracts = Contract.arel_table
      roles = Role.arel_table
      users_roles = Arel::Table.new(:users_roles)

      users_roles_on = users_roles.create_on(roles[:id].eq(users_roles[:role_id])).and(users_roles[:user_id].eq(user.id))
      users_roles_join = users_roles.create_join(users_roles, users_roles_on)

      # manager role with group, metering_pointm organization resource
      # or admin role for any resource
      roles_contracts_on = roles
        .create_on(roles[:name].eq('manager')
                    .and(
                      roles[:resource_id].eq(contracts[:group_id]).and(roles[:resource_type].eq(Group.to_s))
                      .or(roles[:resource_id].eq(contracts[:metering_point_id]).and(roles[:resource_type].eq(MeteringPoint.to_s)))
                      .or(roles[:resource_id].eq(contracts[:organization_id]).and(roles[:resource_type].eq(Organization.to_s)))
                    )
                    .or(roles[:name].eq('admin')
                         .and(roles[:resource_id].eq(nil))))

      roles_contracts_join = roles.create_join(roles, roles_contracts_on)

      joins(roles_contracts_join, users_roles_join)
    else
      where("1=0") #empty set
    end
  end

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

  def self.search_attributes
    [:tariff, :mode, :signing_user, :username, address: [:city, :state, :street_name]]
  end

  def self.filter(search)
    do_filter(search, *search_attributes)
  end

  def login_required?
    if self.organization
      self.organization.slug == 'discovergy' ||  self.organization.slug == 'mysmartgrid'
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
        user.send_notification("success", I18n.t("valid_credentials"), I18n.t("your_credentials_have_been_checked_and_are_valid", contract: contract.mode), contract_path(self))
      else
        user.send_notification("danger", I18n.t("invalid_credentials"), I18n.t("your_credentials_have_been_checked_and_are_invalid", contract: contract.mode), contract_path(self))
      end
    end
  end



private


  def validates_credentials
    if self.mode == 'metering_point_operator_contract' && self.metering_point && self.metering_point.meter
      crawler = Crawler.new(self.metering_point)
      if crawler.valid_credential?
        self.update_columns(valid_credentials: true)
        #self.send_notification_credentials(true)
        copy_contract(:group) if self.group
        if self.metering_point && self.metering_point.meter
          copy_contract(:metering_point)
          self.metering_point.meter.update_columns(smart: true)
          self.metering_point.meter.save
        end
      else
      end
    end
  end


  def copy_contract(resource)
    if resource == :group
      @metering_points = self.group.metering_points.without_externals
    elsif resource == :metering_point
      @metering_points = self.metering_point.meter.metering_points
    end
    @metering_points.each do |metering_point|
      if metering_point.contracts.metering_point_operators.empty?
        @contract = self
        @contract2 = Contract.new(mode: @contract.mode, price_cents: @contract.price_cents, organization: @contract.organization, username: @contract.username, password: @contract.password)
        @contract2.metering_point = metering_point
        @contract2.save
      end
    end
  end
end










