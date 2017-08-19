describe Buzzn::Localpool::TotalAccountedEnergy do

  entity(:reference) { {} }
  entity(:total) do
    total = Buzzn::Localpool::TotalAccountedEnergy.new(Fabricate(:localpool))
    i = 0
    Buzzn::AccountedEnergy::SINGLE_LABELS.each do |label|
      i += 1
      energy = Buzzn::AccountedEnergy.new(Buzzn::Math::Energy.new(i, :mega), rand(2000), rand(3000), rand(4000))
      energy.label = label
      (reference[label] ||= []) << energy
      total.add(energy)
    end
    Buzzn::AccountedEnergy::MULTI_LABELS.each do |label|
      2.times.each do
        i += 1
        energy = Buzzn::AccountedEnergy.new(Buzzn::Math::Energy.new(i, :mega), rand(2000), rand(3000), rand(4000))
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
      "production_pv"=>Buzzn::Math::Energy.new(15, :mega),
      "production_chp"=>Buzzn::Math::Energy.new(19, :mega),
      "other"=>Buzzn::Math::Energy.new(23, :mega),
      "consumption_lsn_full_eeg"=>Buzzn::Math::Energy.new(27, :mega),
      "consumption_lsn_reduced_eeg"=>Buzzn::Math::Energy.new(31, :mega),
      "consumption_third_party"=>Buzzn::Math::Energy.new(35, :mega)
    }
    Buzzn::AccountedEnergy::MULTI_LABELS.each do |label|
      expect(total.sum(label)).to eq expected[label]
    end
  end

  it 'total production' do
     expect(total.total_production).to eq Buzzn::Math::Energy.new(34, :mega)
  end

  it 'production pv' do
     expect(total.production_pv).to eq Buzzn::Math::Energy.new(15, :mega)
  end

  it 'production chp' do
     expect(total.production_chp).to eq Buzzn::Math::Energy.new(19, :mega)
  end

  it 'total consumption by power taker' do
     expect(total.total_consumption_power_taker).to eq Buzzn::Math::Energy.new(58, :mega)
  end

  it 'consumption power taker full eeg' do
     expect(total.consumption_power_taker_full_eeg).to eq Buzzn::Math::Energy.new(27, :mega)
  end

  it 'consumption power taker reduced eeg' do
     expect(total.consumption_power_taker_reduced_eeg).to eq Buzzn::Math::Energy.new(31, :mega)
  end

  it 'consumption third party' do
     expect(total.consumption_third_party).to eq Buzzn::Math::Energy.new(35, :mega)
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
     expect(total.own_consumption).to eq Buzzn::Math::Energy.new(30, :mega)
  end

  it 'grid feeding corrected' do
    expect(total.grid_feeding_corrected).to eq Buzzn::Math::Energy.new(6, :mega)
  end

  it 'grid consumption corrected' do
    expect(total.grid_consumption_corrected).to eq Buzzn::Math::Energy.new(5, :mega)
  end

  context 'demarcation type NONE' do

    let(:localpool) { total.localpool }

    before do
      def total.demarcation_type
        Buzzn::Localpool::TotalAccountedEnergy::NONE
      end
    end

    it 'grid feeding chp' do
      expect(total.grid_feeding_chp).to eq Buzzn::Math::Energy.new(0, :mega)
      def localpool.energy_generator_type
        Group::Base::CHP
      end
      expect(total.grid_feeding_chp).to eq Buzzn::Math::Energy.new(6, :mega)
    end

    it 'grid feeding pv' do
      expect(total.grid_feeding_pv).to eq Buzzn::Math::Energy.new(0, :mega)
      def localpool.energy_generator_type
        Group::Base::PV
      end
      expect(total.grid_feeding_pv).to eq Buzzn::Math::Energy.new(6, :mega)
    end

    it 'consumption_through_chp' do
      expect(total.consumption_through_chp).to eq Buzzn::Math::Energy.new(13, :mega)
    end

    it 'consumption_through_pv' do
      expect(total.consumption_through_pv).to eq Buzzn::Math::Energy.new(9, :mega)
    end
  end

  context 'demarcation type PV' do

    before do
      def total.demarcation_type
        Buzzn::Localpool::TotalAccountedEnergy::PV
      end
    end

    it 'grid feeding chp' do
      expect(total.grid_feeding_chp).to eq Buzzn::Math::Energy.new(5, :mega)
    end

    it 'grid feeding pv' do
      expect(total.grid_feeding_pv).to eq Buzzn::Math::Energy.new(1, :mega)
    end

    it 'consumption_through_chp' do
      expect(total.consumption_through_chp).to eq Buzzn::Math::Energy.new(14, :mega)
    end

    it 'consumption_through_pv' do
      expect(total.consumption_through_pv).to eq Buzzn::Math::Energy.new(14, :mega)
    end
  end
  
  context 'demarcation type CHP' do

    before do
      def total.demarcation_type
        Buzzn::Localpool::TotalAccountedEnergy::CHP
      end
    end

    it 'grid feeding chp' do
      expect(total.grid_feeding_chp).to eq Buzzn::Math::Energy.new(2, :mega)
    end

    it 'grid feeding pv' do
      expect(total.grid_feeding_pv).to eq Buzzn::Math::Energy.new(4, :mega)
    end

    it 'consumption_through_chp' do
      expect(total.consumption_through_chp).to eq Buzzn::Math::Energy.new(17, :mega)
    end

    it 'consumption_through_pv' do
      expect(total.consumption_through_pv).to eq Buzzn::Math::Energy.new(11, :mega)
    end
  end
end
