Fabricator :meter do
  address   { Faker::AddressDE.street_address }
  public    true
  brand     'discovergy'
  uid       1024000034
  username  'stefan@buzzn.net'
  password  '19200buzzn'
end

Fabricator :meter_justus, from: :meter do
  address   'Fichtenweg 10 Wolfratshausen'
  uid       1124001747
  username  'justus@buzzn.net'
  password  'PPf93TcR'
end