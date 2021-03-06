describe Buzzn::Utils::Energy do

  it 'instantiate via Number' do
    a = Buzzn::Utils::Number.watt_hour(2)
    expect(a).to eq Buzzn::Utils::Energy.new(2)
    expect(a).to eq watt_hour(2)
    expect(a).to be > Buzzn::Utils::Energy::ZERO
    expect(a - a).to eq Buzzn::Utils::Energy::ZERO
    expect(a - a * 2).to be < Buzzn::Utils::Energy::ZERO
  end

  it 'prints nicely' do
    a = watt_hour(2)
    expect(a.to_s(:micro)).to eq '2000000.0 μWh'
    expect(a.to_s(:milli)).to eq '2000.0 mWh'
    expect(a.to_s).to eq '2.0 Wh'
    expect(a.to_s(:kilo)).to eq '0.002 kWh'
    expect(a.to_s(:mega)).to eq '2.0e-06 MWh'
  end
end
