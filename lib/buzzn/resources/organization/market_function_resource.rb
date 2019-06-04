require_relative '../person_resource'
require_relative '../address_resource'

module Organization
  class MarketFunctionResource < Buzzn::Resource::Entity

    model Organization::MarketFunction

    attributes :function,
               :market_partner_id,
               :edifact_email

    has_one :contact_person, PersonResource
    has_one :address, AddressResource

  end
end
