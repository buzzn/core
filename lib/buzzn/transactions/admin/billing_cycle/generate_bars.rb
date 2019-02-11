require_relative '../billing_cycle'

class Transactions::Admin::BillingCycle::GenerateBars < Transactions::Base

  add :register_metas
  map :build_result

  def register_metas(resource:, params:)
    resource.object.localpool.register_metas_by_registers.order(:name).to_a.select(&:consumption?)
  end

  def build_result(resource:, params:, register_metas:, **)
    billings = resource.object.billings
    register_metas.map do |meta|
      billings = billings.select { |billing| billing.contract.register_meta == meta }
      third_party_contracts = meta.contracts.where(type: 'Contract::LocalpoolThirdParty').to_a
      build_register_meta_row(meta, billings, third_party_contracts)
    end
  end

  private

  def build_register_meta_row(meta, billings, third_party_contracts)
    {
      id: meta.id,
      type: 'register_meta',
      name: meta.name,
    }.tap do |h|
      bars_billings = billings_as_json(billings)
      h[:bars] = { array: bars_billings }
    end
  end

  def billings_as_json(billings)
    return [] unless billings
    billings.sort_by(&:begin_date).collect { |billing| billing_as_json(billing) }
  end

  def billing_as_json(billing)
    {
      billing_id:                billing.id,
      full_invoice_number:       billing.full_invoice_number,
      begin_date:                billing.begin_date,
      last_date:                 billing.last_date,
      end_date:                  billing.end_date,
      status:                    billing.status,
      total_amount_before_taxes: billing.total_amount_before_taxes.round(2),
      errors:                    billing.errors.empty? ? {} : billing.errors
    }.tap do |h|
      h[:items] = billing.items.map do |item|
        {
          begin_date:           item.begin_date,
          end_date:             item.end_date,
          energy_price_cents:   item.energy_price_cents.round(2),
          consumed_energy_kwh:  item.consumed_energy_kwh,
          errors:               item.errors.empty? ? {} : item.errors
        }
      end
    end
  end

end
