# coding: utf-8
describe "Device Model" do

  let(:device_manager) { Fabricate(:user) }
  let(:out_device_with_manager) do
    device = Fabricate(:out_device)
    device_manager.add_role(:manager, device)
    device
  end

  let(:out_device_with_register) do
    Fabricate(:out_device_with_register)
  end

  let(:out_device_with_register_with_group) do
    Fabricate(:out_device_with_register_with_group)
  end

  let(:device_member) { Fabricate(:user) }
  let(:in_device_with_member) do
    device = Fabricate(:in_device)
    device_member.add_role(:member, device)
    device
  end

  let(:devices) do
    [in_device_with_member, out_device_with_manager, out_device_with_register, out_device_with_register_with_group]
  end

  it 'filters device', :retry => 3 do
    device = Fabricate(:bhkw_justus)
    Fabricate(:auto_justus)

    [device.manufacturer_name,
     device.manufacturer_product_name].each do |val|
      [val, val.upcase, val.downcase, val[0..4], val[-4..-1]].each do |value|
        devices = Device.filter(value)
        expect(devices.first).to eq device
      end
    end
  end


  it 'can not find anything', :retry => 3 do
    Fabricate(:dach_pv_justus)
    devices = Device.filter('Der Clown ist müde und geht nach Hause.')
    expect(devices.size).to eq 0
  end


  it 'filters device with no params', :retry => 3 do
    Fabricate(:pv_karin)
    Fabricate(:bhkw_stefan)

    devices = Device.filter(nil)
    expect(devices.size).to eq 2
  end

  it 'selects worldreadable devices for anonymous user', :retry => 3 do
    devices # create devices
    expect(Device.readable_by(nil)).to match_array [out_device_with_register_with_group]
  end

  it 'selects all devices by admin', :retry => 3 do
    devices # create devices
    expect(Device.readable_by(Fabricate(:admin))).to match_array devices
  end

  it 'selects devices as manager', :retry => 3 do
    devices # create devices
    expect(Device.readable_by(device_manager)).to match_array [out_device_with_register_with_group, out_device_with_manager]
  end

  it 'selects devices as member', :retry => 3 do
    devices # create devices
    expect(Device.readable_by(device_member)).to match_array [out_device_with_register_with_group]
  end
end
