require 'buzzn/guarded_crud'
class ContractingParty < ActiveRecord::Base
  resourcify
  include Authority::Abilities
  include Buzzn::GuardedCrud

  belongs_to :user
  belongs_to :metering_point

  has_many :contracts

  has_one :address, as: :addressable, dependent: :destroy

  has_one :bank_account, as: :bank_accountable, dependent: :destroy


  belongs_to :organization
  accepts_nested_attributes_for :organization, :reject_if => :all_blank


  validates :legal_entity, presence: true

  def self.readable_by_query(user)
    contracting_party = ContractingParty.arel_table
    if user
      contracting_party[:id].eq(contracting_party[:id])
    else
      contracting_party[:id].eq(contracting_party[:id]).not
    end
  end

  scope :readable_by, -> (user) do
    where(readable_by_query(user))
  end

  def self.legal_entities
    %w{
      natural_person
      company
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
