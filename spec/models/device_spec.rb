describe "Device Model" do

  before do
    create(:device)
    create(:device)
  end

  it 'filters device' do
    device = create(:device)

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

  it 'filters device with no params' do
    devices = Device.filter(nil)
    expect(devices.size).to eq Device.count
  end
end
