require_relative '../billing_cycle'

class Transactions::Admin::BillingCycle::GenerateBars < Transactions::Base

  add :register_metas
  map :build_result

  def register_metas(resource:, params:)
    resource.object.localpool.register_metas_by_registers.order(:name).uniq.to_a.select(&:consumption?)
  end

  def build_result(resource:, params:, register_metas:, **)
    billings = resource.object.billings
    {
      array: register_metas.map do |meta|
        billings_filtered = billings.select { |billing| billing.contract.register_meta == meta }
        third_party_contracts = meta.contracts.where(type: 'Contract::LocalpoolThirdParty').to_a
        build_register_meta_row(meta, billings_filtered, third_party_contracts)
      end
    }
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

  def third_partys_as_json(third_party_contracts)
    return [] unless third_party_contracts
    third_party_contracts.sort_by(&:begin_date).collect do |contract|

    end
  end

  def third_party_as_json(third_party_contract)
    {
      billing_id: 0,
      contract_type: third_party_contract.type,
      full_invoice_number: nil,
      begin_date: third_party_contract
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
