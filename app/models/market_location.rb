class MarketLocation < ActiveRecord::Base

  has_many :contracts
  has_many :registers

end
