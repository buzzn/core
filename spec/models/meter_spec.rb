# coding: utf-8
describe "Meter Model" do

  it 'filters meter' do
    meter = Fabricate(:easy_meter_q3d)
    Fabricate(:meter)

    [meter.manufacturer_name, meter.manufacturer_product_name].each do |val|
      [val, val.upcase, val.downcase, val[0..4], val[-4..-1]].each do |value|
        meters = Meter.filter(value)
        expect(meters.first).to eq meter
      end
    end
  end


  it 'can not find anything' do
    Fabricate(:easy_meter_q3d)
    meters = Meter.filter('Der Clown ist müde und geht nach Hause.')
    expect(meters.size).to eq 0
  end


  it 'filters meter with no params' do
    Fabricate(:easy_meter_q3d)
    Fabricate(:meter)

    meters = Meter.filter(nil)
    expect(meters.size).to eq 2
  end
end
