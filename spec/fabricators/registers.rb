Fabricator :register do
  obis_index       '1-1:8.0'
  variable_tariff  false
  mode             'in'
end

Fabricator :virtual_register_in_hopf, from: :register do
  mode             'in'
  virtual           true
  formula           "44-43+42-39-38" "24-23+22-19-18"
end


Fabricator :register_in, from: :register do
  mode             'in'
end

Fabricator :register_out, from: :register  do
  mode             'out'
end

