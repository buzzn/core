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
  external_id = attributes.delete(:external_id)
  meter = attributes.delete(:resource)
  Meter::Base.transaction do
    meter.update(broker: create(:broker, :discovergy),
                 product_serialnumber: external_id.sub(/EASYMETER_/, ''))
  end
  meter.broker
end

SampleData.brokers = OpenStruct.new(
  pt1:  broker(external_id: 'EASYMETER_60327609', resource: SampleData.contracts.pt1.market_location.register.meter),
  pt2:  broker(external_id: 'EASYMETER_60327610', resource: SampleData.contracts.pt2.market_location.register.meter),
  pt3:  broker(external_id: 'EASYMETER_60327611', resource: SampleData.contracts.pt3.market_location.register.meter),
  pt4:  broker(external_id: 'EASYMETER_60327612', resource: SampleData.contracts.pt4.market_location.register.meter),
  pt5a: broker(external_id: 'EASYMETER_60327613', resource: SampleData.contracts.pt5a.market_location.register.meter),
  pt6:  broker(external_id: 'EASYMETER_60327614', resource: SampleData.contracts.pt6.market_location.register.meter),
  # not sure what meter to use here instead but this one already exists (ecar below)
  #pt7a: broker(external_id: 'EASYMETER_60327605', resource: SampleData.contracts.pt7a.market_location.register.meter),
  pt8:  broker(external_id: 'EASYMETER_60327606', resource: SampleData.contracts.pt8.market_location.register.meter),
  pt9:  broker(external_id: 'EASYMETER_60327607', resource: SampleData.contracts.pt9.market_location.register.meter),
  pt10: broker(external_id: 'EASYMETER_60327608', resource: SampleData.contracts.pt10.market_location.register.meter),
  ecar: broker(external_id: 'EASYMETER_60327605', resource: SampleData.registers.ecar.meter),

  pv:   broker(external_id: 'EASYMETER_60327687', resource: SampleData.registers.pv.meter),
  grid: broker(external_id: 'EASYMETER_60300855', mode: :in_out, resource: SampleData.meters.grid)
)
