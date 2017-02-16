# coding: utf-8
describe Meter::Real do

  it 'filters meter', :retry => 3 do
    meter = Fabricate(:easy_meter_q3d)
    Fabricate(:meter, manufacturer_product_serialnumber: '123432345')

    [meter.manufacturer_name, meter.manufacturer_product_name].each do |val|
      [val, val.upcase, val.downcase, val[0..4], val[-4..-1]].each do |value|
        meters = Meter::Real.filter(value)
        expect(meters.detect{|m| m == meter}).to eq meter
      end
    end
  end


  it 'can not find anything' do
    Fabricate(:easy_meter_q3d)
    meters = Meter::Real.filter('Der Clown ist müde und geht nach Hause.')
    expect(meters.size).to eq 0
  end


  it 'filters meter with no params' do
    Fabricate(:easy_meter_q3d)
    Fabricate(:meter)

    meters = Meter::Real.filter(nil)
    expect(meters.size).to eq 2
  end

  let(:meter) { Fabricate(:meter) }
  let(:second) { Fabricate(:input_meter) }
  let(:register) { meter.registers.first }
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
    expect(Meter::Real.all.readable_by(nil)).to eq []
    expect(Meter::Real.all.readable_by(user)).to eq []
    expect(Meter::Real.all.readable_by(manager)).to eq [meter]
    expect(Meter::Real.all.readable_by(admin)).to match_array [meter, second]
    orphand #create
    expect(Meter::Real.all.readable_by(admin)).to match_array [meter, second, orphand]
  end

  it 'deletes a single meter including its register' do
    meter = Fabricate(:input_meter_with_input_register)
    expect(Register::Base.all.size).to eq 1
    expect(Meter::Base.all.size).to eq 1
    meter.destroy
    expect(Register::Base.all.size).to eq 0
    expect(Meter::Base.all.size).to eq 0
  end

  it 'deletes a two way meter including its registers' do
    meter = Fabricate(:easymeter_60139082)
    expect(Register::Base.all.size).to eq 2
    expect(Meter::Base.all.size).to eq 1
    meter.destroy
    expect(Register::Base.all.size).to eq 0
    expect(Meter::Base.all.size).to eq 0
  end

  it 'deletes one register of a two way meter' do
    meter = Fabricate(:easymeter_60139082)
    expect(Register::Base.all.size).to eq 2
    expect(Meter::Base.all.size).to eq 1
    meter.registers.first.destroy
    expect(Register::Base.all.size).to eq 1
    expect(Meter::Base.all.size).to eq 1
  end

  it 'does not delete register or meter' do
    meter = Fabricate(:input_meter_with_input_register)
    expect(Register::Base.all.size).to eq 1
    expect(Meter::Base.all.size).to eq 1
    expect { meter.registers.first.destroy }.to raise_error Buzzn::NestedValidationError
  end
end
