# coding: utf-8
describe "Device Model" do

  entity(:out_device_with_register) do
    Fabricate(:out_device_with_register)
  end

  entity(:out_device_with_register_with_tribe) do
     Fabricate(:out_device_with_register_with_tribe)
  end


  let!(:devices) do
    [out_device_with_register, out_device_with_register_with_tribe]
  end

  it 'filters device' do
    device = Fabricate(:bhkw_justus)

    [device.manufacturer_name,
     device.manufacturer_product_name].each do |val|
      [val, val.upcase, val.downcase, val[0..4], val[-4..-1]].each do |value|
        devices = Device.filter(value)
        expect(devices).to include device
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
end
