class MarketLocationResource < Buzzn::Resource::Entity

  model MarketLocation

  attributes :name, :kind, :market_location_id

  attributes :updatable, :deletable

  has_one :group
  has_one :register

  has_many :contracts

  def kind
    register.kind
  end

  def name
    object.register.meta.name
  end

end
