Fabricator :meter do
  address   { Faker::AddressDE.street_address }
  public    true
  brand     'discovergy'
  uid       1234567890
  username  'meteruser'
  password  'testtest'
end


Fabricator :meter_stefan, from: :meter do
  address   'Urbanstraße 88 berlin'
  uid       1024000034
  username  'stefan@buzzn.net'
  password  '19200buzzn'
end

Fabricator :meter_jan, from: :meter do
  address   'Hellkamp 57'
  uid       243234534
  username  'jan@buzzn.net'
  password  '19200buzzn'
end