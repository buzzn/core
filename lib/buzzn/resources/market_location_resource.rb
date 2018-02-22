class MarketLocationResource < Buzzn::Resource::Entity

  model MarketLocation

  attributes :name, :kind

  attributes :updatable, :deletable

  has_one :group
  has_one :register

  has_many :contracts

  def kind
    if object.register.label.production?
      :production
    elsif object.register.label.consumption?
      :consumption
    else
      :system
    end
  end

end
