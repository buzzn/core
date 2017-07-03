describe Buzzn::Localpool::CalculateEnergyClassification do

  entity(:localpool) do
    localpool = Fabricate(:localpool_sulz_with_registers_and_readings)
  end
  entity!(:germany_mix) { Fabricate(:energy_mix_germany) }
  entity!(:sulz_supplier_mix) { Fabricate(:sulz_supplier_mix) }

  it 'calculates the right energy classification' do
    total_accounted_energy = Buzzn::Services::ReadingCalculation.new.get_all_energy_in_localpool(localpool, Time.new(2016, 8, 4), nil, 2016)
    result = Buzzn::Localpool::CalculateEnergyClassification.do_calculation(localpool, total_accounted_energy, 6.354, 0.4*6.354, 7.381)

    expect(result.tariff_name).to eq localpool.name
    expect(result.nuclear_ratio).to eq 4.73
    expect(result.coal_ratio).to eq 16.34
    expect(result.gas_ratio).to eq 32.4
    expect(result.other_fossiles_ratio).to eq 0.62
    expect(result.other_renewables_ratio).to eq 0.45
    expect(result.renewables_eeg_ratio).to eq 46.44
  end
end
