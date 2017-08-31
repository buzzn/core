# coding: utf-8
describe Buzzn::Utils::Power do

  it 'instantiate via Number' do
    a = Buzzn::Utils::Number.watt(2)
    expect(a).to eq Buzzn::Utils::Power.new(2)
    expect(a).to eq watt(2)
    expect(a).to be > Buzzn::Utils::Power::ZERO
    expect(a - a).to eq Buzzn::Utils::Power::ZERO
    expect(a - a * 2).to be < Buzzn::Utils::Power::ZERO
  end

  it 'prints nicely' do
    a = watt(2)
    expect(a.to_s(:micro)).to eq '2000000.0 μW'
    expect(a.to_s(:milli)).to eq '2000.0 mW'
    expect(a.to_s).to eq '2.0 W'
    expect(a.to_s(:kilo)).to eq '0.002 kW'
    expect(a.to_s(:mega)).to eq '2.0e-06 MW'
  end
end
