describe Buzzn::Localpool::TotalAccountedEnergy do

  entity(:reference) { {} }
  entity(:total) do
    total = Buzzn::Localpool::TotalAccountedEnergy.new(Fabricate(:localpool))
    i = 0
    Buzzn::AccountedEnergy::SINGLE_LABELS.each do |label|
      i += 1
      energy = Buzzn::AccountedEnergy.new(watt_hour(i), rand(2000), rand(3000), rand(4000))
      energy.label = label
      (reference[label] ||= []) << energy
      total.add(energy)
    end
    Buzzn::AccountedEnergy::MULTI_LABELS.each do |label|
      2.times.each do
        i += 1
        energy = Buzzn::AccountedEnergy.new(watt_hour(i), rand(2000), rand(3000), rand(4000))
        energy.label = label
        (reference[label] ||= []) << energy
        total.add(energy)
      end
    end
    total
  end

  it 'return single values' do
    Buzzn::AccountedEnergy::SINGLE_LABELS.each do |label|
      expect(total[label]).to eq reference[label].first
    end
  end

  it 'return multiple values' do
    Buzzn::AccountedEnergy::MULTI_LABELS.each do |label|
      expect(total[label]).to match_array reference[label]
    end
  end

  it 'sums by label' do
    expected = {
      "production_pv"=>watt_hour(15),
      "production_chp"=>watt_hour(19),
      "other"=>watt_hour(23),
      "consumption_lsn_full_eeg"=>watt_hour(27),
      "consumption_lsn_reduced_eeg"=>watt_hour(31),
      "consumption_third_party"=>watt_hour(35)
    }
    Buzzn::AccountedEnergy::MULTI_LABELS.each do |label|
      expect(total.sum(label)).to eq expected[label]
    end
  end

  it 'total production' do
     expect(total.total_production).to eq watt_hour(34)
  end

  it 'production pv' do
     expect(total.production_pv).to eq watt_hour(15)
  end

  it 'production chp' do
     expect(total.production_chp).to eq watt_hour(19)
  end

  it 'total consumption by power taker' do
     expect(total.total_consumption_power_taker).to eq watt_hour(58)
  end

  it 'consumption power taker full eeg' do
     expect(total.consumption_power_taker_full_eeg).to eq watt_hour(27)
  end

  it 'consumption power taker reduced eeg' do
     expect(total.consumption_power_taker_reduced_eeg).to eq watt_hour(31)
  end

  it 'consumption third party' do
     expect(total.consumption_third_party).to eq watt_hour(35)
  end

  it 'count power-taker full eeg' do
     expect(total.count_power_taker_full_eeg).to eq 2
  end

  it 'count power-taker reduced eeg' do
     expect(total.count_power_taker_reduced_eeg).to eq 2
  end

  it 'count third party' do
     expect(total.count_third_party).to eq 2
  end

  it 'own consumption' do
     expect(total.own_consumption).to eq watt_hour(30)
  end

  it 'grid feeding corrected' do
    expect(total.grid_feeding_corrected).to eq watt_hour(6)
  end

  it 'grid consumption corrected' do
    expect(total.grid_consumption_corrected).to eq watt_hour(5)
  end

  context 'demarcation type NONE' do

    let(:localpool) { total.localpool }

    before do
      def total.demarcation_type
        Buzzn::Localpool::TotalAccountedEnergy::NONE
      end
    end

    it 'grid feeding chp' do
      expect(total.grid_feeding_chp).to eq watt_hour(0)
      def localpool.energy_generator_type
        Group::Base::CHP
      end
      expect(total.grid_feeding_chp).to eq watt_hour(6)
    end

    it 'grid feeding pv' do
      expect(total.grid_feeding_pv).to eq watt_hour(0)
      def localpool.energy_generator_type
        Group::Base::PV
      end
      expect(total.grid_feeding_pv).to eq watt_hour(6)
    end

    it 'consumption_through_chp' do
      expect(total.consumption_through_chp).to eq watt_hour(13)
    end

    it 'consumption_through_pv' do
      expect(total.consumption_through_pv).to eq watt_hour(9)
    end
  end

  context 'demarcation type PV' do

    before do
      def total.demarcation_type
        Buzzn::Localpool::TotalAccountedEnergy::PV
      end
    end

    it 'grid feeding chp' do
      expect(total.grid_feeding_chp).to eq watt_hour(5)
    end

    it 'grid feeding pv' do
      expect(total.grid_feeding_pv).to eq watt_hour(1)
    end

    it 'consumption_through_chp' do
      expect(total.consumption_through_chp).to eq watt_hour(14)
    end

    it 'consumption_through_pv' do
      expect(total.consumption_through_pv).to eq watt_hour(14)
    end
  end

  context 'demarcation type CHP' do

    before do
      def total.demarcation_type
        Buzzn::Localpool::TotalAccountedEnergy::CHP
      end
    end

    it 'grid feeding chp' do
      expect(total.grid_feeding_chp).to eq watt_hour(2)
    end

    it 'grid feeding pv' do
      expect(total.grid_feeding_pv).to eq watt_hour(4)
    end

    it 'consumption_through_chp' do
      expect(total.consumption_through_chp).to eq watt_hour(17)
    end

    it 'consumption_through_pv' do
      expect(total.consumption_through_pv).to eq watt_hour(11)
    end
  end
end
