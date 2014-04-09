class MeteringPoint < ActiveRecord::Base
  resourcify
  include Authority::Abilities

  belongs_to :location

  has_one :meter
  accepts_nested_attributes_for :meter, reject_if: :all_blank

  has_one :contracting_party

  has_many :external_contracts, as: :external_contractable
  accepts_nested_attributes_for :external_contracts

end
