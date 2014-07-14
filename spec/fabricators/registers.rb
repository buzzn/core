Fabricator :register do
  obis_index       '1-1:8.0'
  variable_tariff  false
  mode             'in'
end

Fabricator :register_in, from: :register do
  mode             'in'
end

Fabricator :register_out, from: :register  do
  mode             'out'
end