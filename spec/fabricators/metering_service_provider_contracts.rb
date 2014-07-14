Fabricator :metering_service_provider_contract do
  organization  { Organization.where(name: 'discovergy').first }
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