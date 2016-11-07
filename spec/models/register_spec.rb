describe "Register Model" do

  xit 'filters registers'

  it 'creates single register with in metering_point and meter' do
    metering_point = Fabricate(:metering_point, mode: 'in')
    meter = Fabricate(:meter)
    register = Fabricate(:in_register, metering_point: metering_point, meter: meter)
    expect(register.metering_point).to eq metering_point
    expect(register.meter).to eq meter
    expect(register.obis).to eq "1-0:1.8.0"
  end

  it 'creates single register with out metering_point and meter' do
    metering_point = Fabricate(:metering_point, mode: 'out')
    meter = Fabricate(:meter)
    register = Fabricate(:out_register, metering_point: metering_point, meter: meter)
    expect(register.metering_point).to eq metering_point
    expect(register.meter).to eq meter
    expect(register.obis).to eq "1-0:2.8.0"
  end

  it 'creates two registers with in_out metering_point and one meter' do
    metering_point = Fabricate(:metering_point, mode: 'in_out')
    meter = Fabricate(:meter)
    out_register = Fabricate(:out_register, metering_point: metering_point, meter: meter)
    in_register = Fabricate(:in_register, metering_point: metering_point, meter: meter)
    expect(metering_point.registers.size).to eq 2
    expect(metering_point.registers.inputs).to eq [in_register]
    expect(metering_point.registers.outputs).to eq [out_register]
    expect(metering_point.meter).to eq meter
    expect(meter.registers.size).to eq 2
    expect(meter.metering_points).to eq [metering_point]
  end

  it 'creates two registers with two metering_points and one meter' do
    in_metering_point = Fabricate(:metering_point, mode: 'in')
    out_metering_point = Fabricate(:metering_point, mode: 'out')
    meter = Fabricate(:meter)
    out_register = Fabricate(:out_register, metering_point: out_metering_point, meter: meter)
    in_register = Fabricate(:in_register, metering_point: in_metering_point, meter: meter)
    expect(in_metering_point.registers.inputs).to eq [in_register]
    expect(out_metering_point.registers.outputs).to eq [out_register]
    expect(out_metering_point.registers.inputs).to eq []
    expect(in_metering_point.registers.outputs).to eq []
    expect(in_metering_point.meter).to eq meter
    expect(out_metering_point.meter).to eq meter
    expect(meter.registers.size).to eq 2
    expect(meter.metering_points.size).to eq 2
  end

  xit 'creates two registers with one metering_point and two meters'

end
