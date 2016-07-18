# coding: utf-8
describe "Device Model" do

  it 'filters device' do
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


  it 'can not find anything' do
    Fabricate(:dach_pv_justus)
    devices = Device.filter('Der Clown ist müde und geht nach Hause.')
    expect(devices.size).to eq 0
  end


  it 'filters device with no params' do
    Fabricate(:pv_karin)
    Fabricate(:bhkw_stefan)

    devices = Device.filter(nil)
    expect(devices.size).to eq 2
  end
end
