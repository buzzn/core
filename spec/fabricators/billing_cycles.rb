# coding: utf-8
Fabricator :billing_cycle do
  begin_date  { Time.now.beginning_of_year - 1.year }
  end_date    { Time.now.end_of_year - 1.year }
  name        'some-billing-cycle-name'
end

Fabricator :billing_cycle_sulz, from: :billing_cycle do
  begin_date  { Time.new(2016, 8, 4) }
  end_date    { Time.new(2016, 12, 31) }
  name        'Year 2016'
end