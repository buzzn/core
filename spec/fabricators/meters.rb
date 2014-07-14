Fabricator :meter do
  i = 1
  manufacturer_name           'Elster'
  manufacturer_product_number 'AS 1440'
  manufacturer_device_number   {3353984 + (i += 1)}
  virtual                      false
  registers                    { [Fabricate(:register_in)] }
end



# Justus easymeter fur verbrauch
Fabricator :easymeter_1124001747, from: :meter do
  manufacturer_name           'Easymeter'
  manufacturer_product_number 'Q3D'
  manufacturer_device_number  '1124001747'
  registers                    { [Fabricate(:register_in)] }
  #equipments                   { [Fabricate(:equipment)] }
end

# Stefan easymeter fur verbrauch
Fabricator :easymeter_1024000034, from: :meter do
  manufacturer_name           'Easymeter'
  manufacturer_product_number 'Q3D'
  manufacturer_device_number  '1024000034'
  registers                    { [Fabricate(:register_out)] }
  #equipments                   { [Fabricate(:equipment)] }
end


# karins meter fur die pv anlange
Fabricator :easymeter_60051431, from: :meter do
  manufacturer_name           'Easymeter'
  manufacturer_product_number 'Q3D'
  manufacturer_device_number  '60051431'
  registers                    { [Fabricate(:register_out)] }
  #equipments                   { [Fabricate(:equipment)] }
end
