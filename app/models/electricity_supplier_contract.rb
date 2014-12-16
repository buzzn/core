class ElectricitySupplierContract < ActiveRecord::Base
  resourcify
  include Authority::Abilities
  has_paper_trail

  monetize :price_cents

  belongs_to :contracting_party
  belongs_to :organization
  belongs_to :metering_point

  has_one :address, as: :addressable
  accepts_nested_attributes_for :address, :reject_if => :all_blank

  has_one :bank_account, as: :bank_accountable
  accepts_nested_attributes_for :bank_account, :reject_if => :all_blank


  def name
    metering_point.name if metering_point
  end

end
