module Register
  class MetaResource < Buzzn::Resource::Entity

    model Meta

    attributes :name,
               :kind,
               :label,
               :market_location_id,
               :observer_enabled,
               :observer_min_threshold,
               :observer_max_threshold,
               :observer_offline_monitoring

    attributes :updatable, :deletable

    has_one :group
    has_one :register

    has_many :contracts

    def type
      'register_meta'
    end

    def group
      register.group
    end

    def market_location_id
      object.market_location&.market_location_id
    end

  end
end
