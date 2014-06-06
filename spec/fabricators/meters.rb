Fabricator :meter do
  i = 1
  manufacturer_name           'Elster'
  manufacturer_product_number 'AS 1440'
  manufacturer_device_number   {3353984 + (i += 1)}
  virtual                     false
end


Fabricator :meter_justus, from: :meter do
  manufacturer_device_number   1124001747
  operator  'discovergy'
  username  'justus@buzzn.net'
  password  'PPf93TcR'
end