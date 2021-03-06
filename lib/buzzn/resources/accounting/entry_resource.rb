module Accounting
  class EntryResource < Buzzn::Resource::Entity
    require_relative '../contract/base_resource'

    model Accounting::Entry

    attributes :amount,
               :comment,
               :external_reference,
               :external_settled_at

    has_one :contract, Contract::BaseResource

  end
end
