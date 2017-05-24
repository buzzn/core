describe Buzzn::Localpool::CalculateEnergyClassification do

  entity(:localpool) do
    localpool = Fabricate(:localpool_sulz_with_registers_and_readings)
  end
  entity!(:germany_mix) { Fabricate(:energy_mix_germany) }
  entity!(:sulz_supplier_mix) { Fabricate(:sulz_supplier_mix) }

  it 'calculates the right energy classification' do
    total_accounted_energy = Buzzn::Localpool::ReadingCalculation.get_all_energy_in_localpool(localpool, Time.new(2016, 8, 4), nil, 2016)
    result = Buzzn::Localpool::CalculateEnergyClassification.do_calculation(localpool, total_accounted_energy, 6.354, 0.4*6.354, 7.381)
    puts result.inspect
  end
end