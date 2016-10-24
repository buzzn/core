require 'buzzn/guarded_crud'
class ContractingParty < ActiveRecord::Base
  resourcify
  include Authority::Abilities
  include Buzzn::GuardedCrud

  belongs_to :user
  belongs_to :metering_point

  has_many :owned_contracts, class_name: 'Contract', foreign_key: 'contract_owner_id'
  has_many :assigned_contracts, class_name: 'Contract', foreign_key: 'contract_beneficiary_id'

  has_one :address, as: :addressable, dependent: :destroy

  has_one :bank_account, as: :bank_accountable, dependent: :destroy


  belongs_to :organization
  accepts_nested_attributes_for :organization, :reject_if => :all_blank


  def self.legal_entities
    %w{
      natural_person
      company
    }.map(&:to_sym)
  end

  validates :legal_entity, :inclusion => {:in => legal_entities.collect(&:to_s)}

  validate :validates_organization

  def validates_organization
    if legal_entity == 'company' || organization
      unless legal_entity == 'company' && organization
        errors.add(:legal_entity, "an #{self.class} for a company needs an Organization")
      end
    end
  end

  def contracts
    Contract.where("contract_owner_id = ? OR contract_beneficiary_id = ?", self.id, self.id)
  end

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

  def self.guarded_prepare(current_user, params)
    if user_id = params.delete(:user_id)
      params[:user] = User.guarded_retrieve(current_user, user_id)
    end
    if organization_id = params.delete(:organization_id)
      params[:organization] = Organization.guarded_retrieve(current_user,
                                                            organization_id)
    end
    if metering_point_id = params.delete(:metering_point_id)
      params[:metering_point] = MeteringPoint.guarded_retrieve(current_user,
                                                               metering_point_id)
    end
    params
  end
end
