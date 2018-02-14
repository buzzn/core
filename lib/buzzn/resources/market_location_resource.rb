class MarketLocationResource < Buzzn::Resource::Entity

  model MarketLocation

  attributes :name

  attributes :updatable, :deletable

  has_one :group
  has_one :register

  has_many :contracts

end
