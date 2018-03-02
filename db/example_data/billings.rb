def billing_from_contract(contract)
  date_range = contract.begin_date...contract.end_date
  Billing.create!(
    total_energy_consumption_kwh: 0,
    total_price_cents:            0,
    prepayments_cents:            0,
    receivables_cents:            0,
    date_range:                   date_range,
    contract:                     contract,
    status:                       'closed',
    invoice_number:               "BZ-#{format('%05d', Billing.count + 1)}",
    bricks: [Billing::BrickBuilder.from_contract(contract, Date.new(2000, 1, 1)...Date.new(2100, 1, 1))]
  )
end

SampleData.billings = OpenStruct.new

# generate one closed billing for all ended contracts
ended_contracts = SampleData.contracts.each_pair.select { |key, contract| contract.ended? }
ended_contracts.each do |key, contract|
  SampleData.billings.send("#{key}=", billing_from_contract(contract))
end
