class ContractingParty < ActiveRecord::Base
  resourcify
  include Authority::Abilities

  belongs_to :user, inverse_of: :contracting_party
  belongs_to :metering_point

  has_many :contracts

  has_one :address, as: :addressable
  accepts_nested_attributes_for :address, :reject_if => :all_blank

  has_one :bank_account, as: :bank_accountable
  accepts_nested_attributes_for :bank_account, :reject_if => :all_blank

  belongs_to :organization
  accepts_nested_attributes_for :organization, :reject_if => :all_blank



  validates :legal_entity, presence: true


  def private?
    if legal_entity == 'me'
      true
    else
      false
    end
  end

  def name
    if legal_entity == 'me'
      user.name
    else
      "#{user.name} for #{organization.name}"
    end
  end

end
