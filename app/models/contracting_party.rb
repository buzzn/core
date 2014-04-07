class ContractingParty < ActiveRecord::Base
  resourcify
  include Authority::Abilities

  belongs_to :metering_point

  has_many :contracts

  has_one :address, as: :addressable
  accepts_nested_attributes_for :address, :reject_if => :all_blank

  has_one :bank_account, as: :bank_accountable
  accepts_nested_attributes_for :bank_account, :reject_if => :all_blank

  has_one :organization, as: :organizationable
  accepts_nested_attributes_for :organization, :reject_if => :all_blank

  def name
    self.id
  end

end
