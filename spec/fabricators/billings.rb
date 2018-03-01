Fabricator :billing do
  status                        { Billing.status[:open] }
  total_energy_consumption_kwh  1000
  total_price_cents             30000
  prepayments_cents             29000
  receivables_cents             1000
  invoice_number                '12345678-987'
  begin_date                    { Date.today }
  end_date                      { Date.today + 1.year }
end
