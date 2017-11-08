#
# Brokers
#
# Keeping it simple -- rather than setting the broker through the contract --> register --> brokers chain,
# assign the brokers here.
# It would be better if the external id of the broker was inferred by meter manufacturer name + serialnumber,
# but that's not implemented yet.
#
#
#

def broker(attributes)
  create(:broker, :discovergy, attributes.merge(
    provider_login:    ENV['DISCOVERGY_LOGIN'],
    provider_password: ENV['DISCOVERGY_PASSWORD']
  ))
end

SampleData.brokers = OpenStruct.new(
  pt1:  broker(external_id: 'EASYMETER_60327609', resource: SampleData.contracts.pt1.register.meter),
  pt2:  broker(external_id: 'EASYMETER_60327610', resource: SampleData.contracts.pt2.register.meter),
  pt3:  broker(external_id: 'EASYMETER_60327611', resource: SampleData.contracts.pt3.register.meter),
  pt4:  broker(external_id: 'EASYMETER_60327612', resource: SampleData.contracts.pt4.register.meter),
  pt5a: broker(external_id: 'EASYMETER_60327613', resource: SampleData.contracts.pt5a.register.meter),
  pt6:  broker(external_id: 'EASYMETER_60327614', resource: SampleData.contracts.pt6.register.meter),
  pt7a: broker(external_id: 'EASYMETER_60327605', resource: SampleData.contracts.pt7a.register.meter),
  pt8:  broker(external_id: 'EASYMETER_60327606', resource: SampleData.contracts.pt8.register.meter),
  pt9:  broker(external_id: 'EASYMETER_60327607', resource: SampleData.contracts.pt9.register.meter),
  pt10: broker(external_id: 'EASYMETER_60327608', resource: SampleData.contracts.pt10.register.meter),

  pv:   broker(external_id: 'EASYMETER_60327687', resource: SampleData.registers.pv.meter),
  grid: broker(external_id: 'EASYMETER_60300855', mode: :in_out, resource: SampleData.meters.grid)
)
