class Contract < ActiveRecord::Base
  belongs_to :contracting_party
  has_one :meter
  has_one :address, as: :addressable
  has_one :bank_account, as: :bank_accountable
end
