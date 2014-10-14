Fabricator :metering_point_operator_contract do
  organization  { Organization.find('discovergy') }
  username      'test@buzzn.net'
  password      'xxxxxx'
end

Fabricator :mpoc_justus, from: :metering_point_operator_contract do
  username 'justus@buzzn.net'
  password 'PPf93TcR'
end

Fabricator :mpoc_stefan, from: :metering_point_operator_contract do
  username 'stefan@buzzn.net'
  password '19200buzzn'
end

Fabricator :mpoc_karin, from: :metering_point_operator_contract do
  username 'karin.smith@solfux.de'
  password '19200buzzn'
end

Fabricator :mpoc_buzzn_metering, from: :metering_point_operator_contract do
  organization  { Organization.find('buzzn-metering') }
  username 'team@buzzn-metering.de'
  password 'Zebulon_4711'
end

Fabricator :mpoc_christian, from: :metering_point_operator_contract do
  username 'christian@buzzn.net'
  password 'Roentgen11smartmeter'
end

Fabricator :mpoc_philipp, from: :metering_point_operator_contract do
  username 'info@philipp-osswald.de'
  password 'Null8fünfzehn'
end


