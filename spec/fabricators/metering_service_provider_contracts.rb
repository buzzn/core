Fabricator :metering_service_provider_contract do
  organization  { Organization.find('discovergy') }
  username      'test@buzzn.net'
  password      'xxxxxx'
end

Fabricator :mspc_justus, from: :metering_service_provider_contract do
  username 'justus@buzzn.net'
  password 'PPf93TcR'
end

Fabricator :mspc_stefan, from: :metering_service_provider_contract do
  username 'stefan@buzzn.net'
  password '19200buzzn'
end

Fabricator :mspc_karin, from: :metering_service_provider_contract do
  username 'karin.smith@solfux.de'
  password '19200buzzn'
end

Fabricator :mspc_buzzn_metering, from: :metering_service_provider_contract do
  organization  { Organization.finde('buzzn-metering') }
  username 'team@buzzn.net'
  password '19200buzzn'
end
