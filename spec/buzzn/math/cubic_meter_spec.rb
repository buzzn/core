# coding: utf-8
describe Buzzn::Math::CubicMeter do

  it 'instantiate via Number' do
    a = Buzzn::Math::Number.cubic_meter(2)
    expect(a).to eq Buzzn::Math::CubicMeter.new(2)
    expect(a).to eq cubic_meter(2)
    expect(a).to be > Buzzn::Math::CubicMeter::ZERO
    expect(a - a).to eq Buzzn::Math::CubicMeter::ZERO
    expect(a - a * 2).to be < Buzzn::Math::CubicMeter::ZERO
  end

  it 'prints nicely' do
    a = cubic_meter(2)
    # NOTE this is probably wrong beside the default
    expect(a.to_s(:micro)).to eq '2000000.0 μm³'
    expect(a.to_s(:milli)).to eq '2000.0 mm³'
    expect(a.to_s).to eq '2.0 m³'
    expect(a.to_s(:kilo)).to eq '0.002 km³'
    expect(a.to_s(:mega)).to eq '2.0e-06 Mm³'
  end
end
