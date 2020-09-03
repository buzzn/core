require_relative '../builders/billing/item_builder'

#
# Returns all unbilled billing items for a list of market locations and a date range.
# The unbilled billing items are unsaved, so that they can be used for display only or persistance within
# a Billing and maybe BillingCycle.
#
class Services::UnbilledBillingItemsFactory

  # Returns this structure:
  # [
  #   {
  #    register_meta: <Register::Meta id:5>
  #    contracts: [
  #      {
  #        contract: <Contract id:5>
  #        billing_items: [
  #          <BillingItem (not persisted)>
  #        ]
  #      }
  #    ]
  #
  #   }
  # ]
  def call(register_metas:, date_range:, vat:)
    register_metas.collect do |register_meta|
      {
        register_meta: register_meta,
        contracts: contracts_with_items(register_meta, date_range, vat)
      }
    end
  end

  private

  def unbilled_contracts(register_meta, date_range)
    return [] if date_range_zero?(date_range)
    unbilled_date_range = unbilled_date_range(register_meta, date_range)
    contracts = register_meta.contracts_in_date_range(unbilled_date_range)
    [contracts, unbilled_date_range]
  end

  def contracts_with_items(register_meta, date_range, vat)
    contracts, unbilled_date_range = unbilled_contracts(register_meta, date_range)
    contracts.collect do |contract|
      {
        contract: contract,
        # We don't handle register and tariff changes yet, so we always return an array with one item, rather than 2+
        # later (register and tariff changes will cause new items).
        items: [build_item(contract, unbilled_date_range, vat)]
      }
    end
  end

  def build_item(contract, date_range, vat)
    Builders::Billing::ItemBuilder.from_contract(contract, contract.register_meta.registers.first, date_range, contract.tariffs.first, vat)
  end

  # Ruby can't calculate the length (in days) of a range object when the range is defined with dates -- it always returns nil.
  # TODO: use exclude_end? to prevent one-off errors
  def date_range_zero?(date_range)
    date_range.last == date_range.first
  end

  def unbilled_date_range(register_meta, date_range)
    last_billing = last_billing_for(register_meta, date_range)
    last_billing ? last_billing.end_date...date_range.last : date_range
  end

  def last_billing_for(register_meta, date_range)
    register_meta.billings_in_date_range(date_range).order(:end_date).last
  end

end
