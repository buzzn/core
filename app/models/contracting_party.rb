class ContractingParty < ActiveRecord::Base
  resourcify
  include Authority::Abilities

  belongs_to :user
  belongs_to :metering_point

  has_many :contracts

  has_one :address, as: :addressable
  accepts_nested_attributes_for :address, :reject_if => :all_blank

  has_one :bank_account, as: :bank_accountable
  accepts_nested_attributes_for :bank_account, :reject_if => :all_blank

  belongs_to :organization
  accepts_nested_attributes_for :organization, :reject_if => :all_blank


  validates :legal_entity, presence: true



  def self.legal_entities
    %w{
      natural_person
      company
      cooperative
      corporation
    }.map(&:to_sym)
  end



  def natural_person?
    legal_entity == 'natural_person'
  end

  def name
    if legal_entity == 'natural_person'
      user.name
    else
      "#{user.name} for #{organization.name}"
    end
  end

end
