# coding: utf-8
describe "Meter Model" do

  it 'filters meter', :retry => 3 do
    meter = Fabricate(:easy_meter_q3d)
    Fabricate(:meter, manufacturer_product_serialnumber: '123432345')

    [meter.manufacturer_name, meter.manufacturer_product_name].each do |val|
      [val, val.upcase, val.downcase, val[0..4], val[-4..-1]].each do |value|
        meters = Meter.filter(value)
        expect(meters.detect{|m| m == meter}).to eq meter
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

  let(:meter) { Fabricate(:meter) }
  let(:second) do
    second = Fabricate(:meter)
    Fabricate(:input_register, meter: second)
    second
  end
  let(:register) { Fabricate(:input_register, meter: meter) }
  let(:user) { Fabricate(:user) }
  let(:admin) do
    admin = Fabricate(:user)
    admin.add_role(:admin, nil)
    admin
  end
  let(:manager) do
    manager = Fabricate(:user)
    manager.add_role(:manager, register)
    manager
  end
  let(:orphand) { Fabricate(:meter) }

  it 'is restricting readable_by' do
     # orphand without register
    expect(Meter.all.readable_by(nil)).to eq []
    expect(Meter.all.readable_by(user)).to eq []
    expect(Meter.all.readable_by(manager)).to eq [meter]
    expect(Meter.all.readable_by(admin)).to match_array [meter, second]
    orphand #create
    expect(Meter.all.readable_by(admin)).to match_array [meter, second, orphand]
  end
end
