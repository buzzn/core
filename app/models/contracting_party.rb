require 'buzzn/guarded_crud'
class ContractingParty < ActiveRecord::Base
  resourcify
  include Authority::Abilities
  include Buzzn::GuardedCrud

  belongs_to :user
  belongs_to :register, class_name: Register::Base, foreign_key: :register_id

  has_many :owned_contracts, class_name: 'Contract', foreign_key: 'contractor_id'
  has_many :assigned_contracts, class_name: 'Contract', foreign_key: 'customer_id'

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

  validate :validate_invariants

  def validate_invariants
    case legal_entity 
    when 'company'
      validate_organization
    when 'natural_person'
      validate_natural_person
    else
      errors.add(:legal_entity, "unknown legal entity '#{legal_entity}'")
    end
  end

  def validate_natural_person
    if bank_account.nil?
      errors.add(:bank_account, 'Missing bank-account')
    end
    # errors.add(:sales_tax_number, 'a natural person has no sales tax number') if sales_tax_number
    # errors.add(:sales_tax_number, 'a natural person has no tax rate') if tax_rate
    # errors.add(:sales_tax_number, 'a natural person has no tax number') if tax_number
    errors.add(:organization, "a natural person has no Organization") if organization
  end

  def validate_organization
    #errors.add(:sales_tax_number, 'a company needs a sales tax number') if sales_tax_number
    #errors.add(:sales_tax_number, 'a company needs a tax rate') if tax_rate
    #errors.add(:sales_tax_number, 'a company needs a tax number') if tax_number
    errors.add(:organization, "a company needs an Organization") unless organization
  end

  def contracts
    Contract.where("contractor_id = ? OR customer_id = ?", self.id, self.id)
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
    if register_id = params.delete(:register_id)
      params[:register] = Register::Base.guarded_retrieve(current_user,
                                                               register_id)
    end
    params
  end
end
