# coding: utf-8
describe Meter::Real do

  entity!(:easymeter) { Fabricate(:easy_meter_q3d) }
  entity!(:meter) { Fabricate(:meter, product_serialnumber: '123432345', product_name: 'SomethingComplicated' ) }
  entity(:second) {  Fabricate(:input_meter) }
  entity(:register) { meter.registers.first }
  entity!(:input_meter) { Fabricate(:input_meter) }

  it 'filters meter' do
    [meter.product_serialnumber, meter.product_name].each do |val|
      [val, val.upcase, val.downcase, val[0..4], val[-4..-1]].each do |value|
        meters = Meter::Real.filter(value)
        expect(meters.detect{|m| m == meter}).to eq meter
      end
    end
  end

  it 'can not find anything' do
    meters = Meter::Real.filter('Der Clown ist müde und geht nach Hause.')
    expect(meters.size).to eq 0
  end

  it 'filters meter with no params' do
    meters = Meter::Real.filter(nil)
    expect(meters.size).to eq Meter::Real.count
  end

  it 'deletes a single meter including its register' do
    rcount = Register::Base.count
    count = Meter::Base.count
    input_meter.destroy
    expect(Register::Base.all.size).to eq rcount - 1
    expect(Meter::Base.all.size).to eq count - 1
  end

  it 'deletes a two way meter including its registers' do
    meter = Fabricate(:easymeter_60139082)
    rcount = Register::Base.count
    count = Meter::Base.count
    meter.destroy
    expect(Register::Base.all.size).to eq rcount - 2
    expect(Meter::Base.all.size).to eq count - 1
  end

  it 'deletes one register of a two way meter' do
    begin
      meter = Fabricate(:easymeter_60139082)
      rcount = Register::Base.count
      count = Meter::Base.count
      meter.registers.first.destroy
      expect(Register::Base.all.size).to eq rcount - 1
      expect(Meter::Base.all.size).to eq count
    ensure
      meter.destroy
    end
  end

  it 'does not delete register or meter' do
    expect { meter.registers.first.destroy }.to raise_error Buzzn::NestedValidationError
  end
end
