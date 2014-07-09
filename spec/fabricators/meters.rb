Fabricator :meter do
  i = 1
  manufacturer_name           'Elster'
  manufacturer_product_number 'AS 1440'
  manufacturer_device_number   {3353984 + (i += 1)}
  virtual                      false
  registers                    { [Fabricate(:register)] }
end

# Justus easymeter 1024000034
Fabricator :easymeter_1024000034, from: :meter do
  manufacturer_name           'Easymeter'
  manufacturer_product_number 'Q3D'
  manufacturer_device_number  '1024000034'
  registers                    { [Fabricate(:register)] }
  #equipments                   { [Fabricate(:equipment)] }
end
