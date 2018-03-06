Fabricator :billing do
  status         { Billing.status[:open] }
  invoice_number '12345678-987'
  begin_date     { Date.today }
  end_date       { Date.today + 1.year }
end
