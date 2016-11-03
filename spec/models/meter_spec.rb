# coding: utf-8
describe "Meter Model" do

  it 'filters meter', :retry => 3 do
    meter = Fabricate(:easy_meter_q3d)
    Fabricate(:meter)

    [meter.manufacturer_name, meter.manufacturer_product_name].each do |val|
      [val, val.upcase, val.downcase, val[0..4], val[-4..-1]].each do |value|
        meters = Meter.filter(value)
        expect(meters.first).to eq meter
      end
    end
  end


  it 'can not find anything', :retry => 3 do
    Fabricate(:easy_meter_q3d)
    meters = Meter.filter('Der Clown ist müde und geht nach Hause.')
    expect(meters.size).to eq 0
  end


  it 'filters meter with no params', :retry => 3 do
    Fabricate(:easy_meter_q3d)
    Fabricate(:meter)

    meters = Meter.filter(nil)
    expect(meters.size).to eq 2
  end

  let(:meter) { meter = Fabricate(:easy_meter_q3d_with_metering_point) }
  let(:second) { Fabricate(:easy_meter_q3d_with_metering_point) }
  let(:user) { Fabricate(:user) }
  let(:admin) do
    admin = Fabricate(:user)
    admin.add_role(:admin, nil)
    admin
  end
  let(:manager) do
    manager = Fabricate(:user)
    manager.add_role(:manager, meter.metering_points.first)
    manager
  end
  let(:orphand) { Fabricate(:meter) }

  it 'is restricting readable_by', :retry => 3 do
     # orphand without metering_point
    expect(Meter.all.readable_by(nil)).to eq []
    expect(Meter.all.readable_by(user)).to eq []
    expect(Meter.all.readable_by(manager)).to eq [meter]
    expect(Meter.all.readable_by(admin)).to match_array [meter, second]
    orphand #create
    expect(Meter.all.readable_by(admin)).to match_array [meter, second, orphand]
  end
end
