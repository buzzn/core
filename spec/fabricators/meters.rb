Fabricator :meter do
  i = 1
  uid           {1024000034 + (i += 1)}
  manufacturer  'ferraris'
end

Fabricator :meter_justus, from: :meter do
  uid       1124001747
  operator  'discovergy'
  username  'justus@buzzn.net'
  password  'PPf93TcR'
end