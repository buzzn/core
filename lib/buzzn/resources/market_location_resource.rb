class MarketLocationResource < Buzzn::Resource::Entity

  attributes :name, :kind, :market_location_id

  attributes :updatable, :deletable

  has_one :group
  has_one :register

  has_many :contracts

  def type
    'market_location'
  end

  def group
    register.group
  end

  def market_location_id
    object.register.meta.market_location&.market_location_id
  end

  def kind
    object.register.kind
  end

  def name
    object.register.meta.name
  end

end
