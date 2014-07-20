Fabricator :meter do
  i = 1
  manufacturer_name           'Elster'
  manufacturer_product_name    'AS 1440'
  manufacturer_product_serialnumber   {3353984 + (i += 1)}
  virtual                      false
  registers                    { [Fabricate(:register_in)] }
end


Fabricator :in_meter, from: :meter do
  registers { [Fabricate(:register_in)] }
end

Fabricator :out_meter, from: :meter do
  registers { [Fabricate(:register_out)] }
end

Fabricator :in_out_meter, from: :meter do
  registers { [Fabricate(:register_in), Fabricate(:register_out)] }
end



# Justus easymeter fur verbrauch
Fabricator :easymeter_1124001747, from: :meter do
  manufacturer_name           'Easymeter'
  manufacturer_product_name   'Q3D'
  manufacturer_product_serialnumber  '1124001747'
  registers                    { [Fabricate(:register_in)] }
  equipments                   { [Fabricate(:equipment)] }
end

# Stefan easymeter fur verbrauch
Fabricator :easymeter_1024000034, from: :meter do
  manufacturer_name           'Easymeter'
  manufacturer_product_name   'Q3D'
  manufacturer_product_serialnumber  '1024000034'
  registers                    { [Fabricate(:register_out)] }
  equipments                   { [Fabricate(:equipment)] }
end


# karins meter fur die pv anlange
Fabricator :easymeter_60051431, from: :meter do
  manufacturer_name           'Easymeter'
  manufacturer_product_name   'Q3D'
  manufacturer_product_serialnumber  '60051431'
  registers                    { [Fabricate(:register_out)] }
  equipments                   { [Fabricate(:equipment)] }
end
