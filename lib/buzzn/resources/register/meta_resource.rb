module Register
  class MetaResource < Buzzn::Resource::Entity

    model Meta

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
      object.market_location&.market_location_id
    end

    def kind
      object.register.nil? ? nil : object.register.kind
    end

  end
end
