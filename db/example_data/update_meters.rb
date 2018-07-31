#
# Update Meters
#

def update_meter(serialnumber:, resource:)
  meter =
    case resource
    when Contract::Base
      resource.register_meta.register.meter
    when Meter::Base
      resource
    else
      warn "can not handle #{meter.class} with #{serialnumber}"
      return
    end
  meter.update(product_serialnumber: serialnumber)
end

update_meter(serialnumber: '60327609', resource: SampleData.contracts.pt1)
update_meter(serialnumber: '60327610', resource: SampleData.contracts.pt2)
update_meter(serialnumber: '60327611', resource: SampleData.contracts.pt3)
update_meter(serialnumber: '60327612', resource: SampleData.contracts.pt4)
update_meter(serialnumber: '60327613', resource: SampleData.contracts.pt5a)
update_meter(serialnumber: '60327614', resource: SampleData.contracts.pt6)
update_meter(serialnumber: '60327605', resource: SampleData.contracts.pt7a)
update_meter(serialnumber: '60327606', resource: SampleData.contracts.pt8)
update_meter(serialnumber: '60327607', resource: SampleData.contracts.pt9a)
update_meter(serialnumber: '60327615', resource: SampleData.contracts.pt9b)
update_meter(serialnumber: '60327608', resource: SampleData.contracts.ecar)
update_meter(serialnumber: '60327687', resource: SampleData.registers.pv.meter)
update_meter(serialnumber: '60300855', resource: SampleData.meters.grid)
