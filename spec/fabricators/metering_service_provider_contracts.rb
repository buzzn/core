Fabricator :metering_service_provider_contract do
  customer_number '324r3f4f4'
  contract_number '443d'
end


Fabricator :mspc_justus, from: :metering_service_provider_contract do
  organization  { Organization.where(name: 'discovergy').first }
  username      'justus@buzzn.net'
  password      'PPf93TcR'
end

Fabricator :mspc_karin, from: :metering_service_provider_contract do
  organization  { Organization.where(name: 'discovergy').first }
  username      'karin.smith@solfux.de'
  password      '19200buzzn'
end