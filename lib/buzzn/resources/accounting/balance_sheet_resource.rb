module Accounting
  class BalanceSheetResource < Buzzn::Resource::Entity
    require_relative '../contract/base_resource'
    require_relative 'entry_resource'

    model Accounting::BalanceSheet

    attributes :total

    has_many :entries, Accounting::EntryResource
    has_one  :contract, Contract::BaseResource

  end
end
