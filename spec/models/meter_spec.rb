describe Meter::Real do

  entity!(:meter) { create(:meter, :real, group: nil) }
  entity!(:group) { create(:localpool) }

  it 'gets a sequence_number if added to a group' do
    expect(meter.group).to eq nil
    expect(meter.sequence_number).to be_nil
    meter.update(group: group)
    expect(meter.reload.sequence_number).to eq 1
    expect(meter.group).to eq group

    expect { meter.update(group: Fabricate(:localpool)) }.to raise_error ArgumentError

    second_meter = create(:meter, :real, group: group)
    expect(second_meter.reload.sequence_number).to eq 2
  end

  it 'generates unique immutable serial numbers for Meter::Virtual' do
    meter1 = create(:meter, :virtual)
    meter2 = create(:meter, :virtual)
    expect(meter1.product_serialnumber).to eq 'VM-1'
    expect(meter2.product_serialnumber).to eq 'VM-2'

    expect { meter1.update(product_serialnumber: 'something') }.to raise_error ActiveRecord::ReadOnlyRecord
  end
end
