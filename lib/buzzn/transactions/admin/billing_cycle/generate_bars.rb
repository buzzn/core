require_relative '../billing_cycle'

class Transactions::Admin::BillingCycle::GenerateBars < Transactions::Base

  add :register_metas
  map :build_result

  def register_metas(resource:, params:)
    resource.object.localpool.register_metas_by_registers.order(:name).uniq.to_a.select(&:consumption?)
  end

  def build_result(resource:, params:, register_metas:, **)
    range = resource.object.begin_date..resource.object.end_date
    billings = resource.object.billings
    {
      array: register_metas.map do |meta|
        billings_filtered = billings.select { |billing| billing.contract.register_meta == meta }
        third_party_contracts = meta.contracts.where(type: 'Contract::LocalpoolThirdParty').to_a
        build_register_meta_row(range, meta, billings_filtered, third_party_contracts)
      end
    }
  end

  private

  def build_register_meta_row(range, meta, billings, third_party_contracts)
    {
      id: meta.id,
      type: 'register_meta',
      name: meta.name,
    }.tap do |h|
      billings_bars = billings_as_json(billings)
      third_party_bars = third_partys_as_json(range, third_party_contracts)
      h[:bars] = { array: billings_bars + third_party_bars }
    end
  end

  def billings_as_json(billings)
    return [] unless billings
    billings.sort_by(&:begin_date).collect { |billing| billing_as_json(billing) }
  end

  def third_partys_as_json(range, third_party_contracts)
    return [] unless third_party_contracts
    third_party_contracts.sort_by(&:begin_date).keep_if { |c| c.begin_date < range.last && (c.end_date.nil? || (c.end_date > range.first)) }.map{ |x| third_party_as_json(range, x) }
  end

  def third_party_as_json(range, third_party_contract)
    minmaxed_range = third_party_contract.minmax_date_range(range)
    {
      billing_id: 0,
      contract_type: CONTRACT_MAP.fetch(third_party_contract.type, 'unknown'),
      full_invoice_number: nil,
      begin_date: third_party_contract.begin_date,
      last_date: third_party_contract.last_date,
      end_date: third_party_contract.end_date,
      fixed_begin_date: minmaxed_range.first,
      fixed_end_date: minmaxed_range.last,
      status: 'open',
      total_consumed_energy_kwh: nil,
      total_amount_before_taxes: nil,
      items: {}
    }
  end

  CONTRACT_MAP = {
    'Contract::MeteringPointOperator' => 'contract_metering_point_operator',
    'Contract::LocalpoolProcessing'   => 'contract_localpool_processing',
    'Contract::LocalpoolPowerTaker'   => 'contract_localpool_power_taker',
    'Contract::LocalpoolThirdParty'   => 'contract_localpool_third_party',
    'Contract::LocalpoolGap'          => 'contract_localpool_gap'
  }

  def billing_as_json(billing)
    {
      billing_id:                billing.id,
      contract_type:             CONTRACT_MAP.fetch(billing.contract.type, 'unknown'),
      full_invoice_number:       billing.full_invoice_number,
      begin_date:                billing.begin_date,
      last_date:                 billing.last_date,
      end_date:                  billing.end_date,
      status:                    billing.status,
      total_consumed_energy_kwh: billing.total_consumed_energy_kwh,
      total_amount_before_taxes: billing.total_amount_before_taxes.nil? ? nil : billing.total_amount_before_taxes.round(2),
      errors:                    billing.errors.empty? ? {} : billing.errors
    }.tap do |h|
      h[:items] = {
        array: billing.items.map do |item|
          {
            begin_date:           item.begin_date,
            end_date:             item.end_date,
            energy_price_cents:   item.energy_price_cents.nil? ? nil : item.energy_price_cents.round(2),
            consumed_energy_kwh:  item.consumed_energy_kwh,
            errors:               item.errors.empty? ? {} : item.errors
          }
        end
      }
    end
  end

end
