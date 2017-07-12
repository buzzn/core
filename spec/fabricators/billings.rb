# coding: utf-8
Fabricator :billing do
  status                        { Billing::OPEN }
  total_energy_consumption_kwh  1000
  total_price_cents             30000
  prepayments_cents             29000
  receivables_cents             1000
  invoice_number                '12345678-987'
  start_reading_id              { Fabricate(:reading).id }
  end_reading_id                { Fabricate(:reading).id }
end
