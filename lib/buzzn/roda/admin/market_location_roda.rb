require_relative '../admin_roda'

module Admin
  class MarketLocationRoda < BaseRoda

    plugin :shared_vars

    route do |r|

      locations = shared[LocalpoolRoda::PARENT].market_locations

      r.get! do
        locations
      end

      r.on :id do |id|
        location = locations.retrieve(id)

        r.get! do
          location
        end
      end
    end

  end
end
