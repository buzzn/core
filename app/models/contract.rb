class Contract < ActiveRecord::Base
  resourcify
  include Authority::Abilities

  has_paper_trail

  belongs_to :contracting_party

  has_one :metering_point

  has_one :address, as: :addressable
  accepts_nested_attributes_for :address, :reject_if => :all_blank

  has_one :bank_account, as: :bank_accountable
  accepts_nested_attributes_for :bank_account, :reject_if => :all_blank

  has_many :external_contract, as: :external_contractable
  accepts_nested_attributes_for :external_contract, :reject_if => :all_blank


  def name
    self.metering_point.name
  end

end
