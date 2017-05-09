# coding: utf-8
describe "Device Model" do

  entity(:device_manager) { Fabricate(:user) }
  entity(:out_device_with_manager) do
    device = Fabricate(:out_device)
    device_manager.add_role(:manager, device)
    device
  end

  entity(:out_device_with_register) do
    Fabricate(:out_device_with_register)
  end

  entity(:out_device_with_register_with_tribe) do
     Fabricate(:out_device_with_register_with_tribe)
  end

  entity(:device_member) { Fabricate(:user) }
  entity(:in_device_with_member) do
    device = Fabricate(:in_device)
    device_member.add_role(:member, device)
    device
  end

  let!(:devices) do
    [in_device_with_member, out_device_with_manager, out_device_with_register, out_device_with_register_with_tribe]
  end

  it 'filters device', :retry => 3 do
    device = Fabricate(:bhkw_justus)

    [device.manufacturer_name,
     device.manufacturer_product_name].each do |val|
      [val, val.upcase, val.downcase, val[0..4], val[-4..-1]].each do |value|
        devices = Device.filter(value)
        expect(devices.first).to eq device
      end
    end
  end


  it 'can not find anything' do
    devices = Device.filter('Der Clown ist müde und geht nach Hause.')
    expect(devices.size).to eq 0
  end


  it 'filters device with no params', :retry => 3 do
    devices = Device.filter(nil)
    expect(devices.size).to eq Device.count
  end

  it 'selects worldreadable devices for anonymous user', :retry => 3 do
    expect(Device.readable_by(nil)).to match_array [out_device_with_register_with_tribe]
  end

  it 'selects all devices by admin' do
    expect(Device.readable_by(Fabricate(:admin))).to match_array Device.all
  end

  it 'selects devices as manager' do
    expect(Device.readable_by(device_manager)).to match_array [out_device_with_register_with_tribe, out_device_with_manager]
  end

  it 'selects devices as member' do
    expect(Device.readable_by(device_member)).to match_array [out_device_with_register_with_tribe]
  end
end
