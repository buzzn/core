describe Register do

  entity!(:urbanstr) do
    Fabricate(:register_urbanstr88, meter: Fabricate(:output_meter))
  end

  entity! :register do
    easymeter_60051560 = Fabricate(:easymeter_60051560)
    easymeter_60051560.broker = Fabricate(:discovergy_broker, meter: easymeter_60051560)
    easymeter_60051560.output_register
  end

  it 'filters register with no params' do
    registers = Register::Base.filter(nil)
    expect(registers).to match_array Register::Base.all
  end

  it 'returns registers by label' do
    consumption = Register::Base.all.consumption.size
    production = Register::Base.all.production_pv.size
    3.times do
      Fabricate(:input_meter)
    end
    3.times do
      Fabricate(:output_meter)
    end
    expect(Register::Base.all.consumption.size).to eq consumption + 3
    expect(Register::Base.all.production_pv.size).to eq production + 3
    expect(Register::Base.all.by_labels(Register::Base.labels[:consumption], Register::Base.labels[:production_pv]).size).to eq consumption + production + 6
    expect(Register::Base.all.by_labels(Register::Base.labels[:grid_feeding], Register::Base.labels[:demarcation_pv]).size).to eq 0
    expect{ Register::Base.all.by_labels('something') }.to raise_error ArgumentError
  end

  describe 'observers' do

    let(:now) { Time.find_zone('Berlin').local(2016, 2, 1, 1, 30, 1) }

    before do
      register.update(observer_enabled: false, observer_offline_monitoring: false)
    end

    xit 'nothing' do |spec|
      Timecop.freeze(now) do
        VCR.use_cassette("models/observe #{spec.metadata[:description].downcase}") do
          register.update observer_enabled: false
          result = register.create_observer_activities
          expect(result).to eq Register::Base::NONE
        end
      end
    end

    xit 'exceeds' do |spec|
      Timecop.freeze(now) do
        VCR.use_cassette("models/observe #{spec.metadata[:description].downcase}") do
          register.update observer_enabled: true, observer_max_threshold: 200, observer_min_threshold: 0
          result = register.create_observer_activities
          expect(result).to eq Register::Base::EXCEEDS
        end
      end
    end

    xit 'undershoots' do |spec|
      Timecop.freeze(now) do
        VCR.use_cassette("models/observe #{spec.metadata[:description].downcase}") do
          register.update observer_enabled: true, observer_min_threshold: 1000, observer_max_threshold: 2000
          result = register.create_observer_activities
          expect(result).to eq Register::Base::UNDERSHOOTS
        end
      end
    end

    xit 'offline' do |spec|
      now = Time.find_zone('Berlin').local(2016, 3, 1, 1, 30, 1)
      Timecop.freeze(now) do
        VCR.use_cassette("models/observe #{spec.metadata[:description].downcase}_first") do
          register.update observer_offline_monitoring: true, last_observed: now.utc
          result = register.create_observer_activities
          expect(result).to eq Register::Base::NONE
        end
      end
      now += 5.minutes
      Timecop.freeze(now) do
        VCR.use_cassette("models/observe #{spec.metadata[:description].downcase}_second") do
          result = register.create_observer_activities
          expect(result).to eq Register::Base::OFFLINE
        end
      end
    end
  end

  describe 'obis' do
    context 'when register is base' do
      it { expect(Register::Base.new.obis).to be_nil }
    end
    context 'when register is real' do
      it { expect { Register::Real.new.obis }.to raise_error(RuntimeError, 'not implemented') }
    end
    context 'when register is input' do
      it { expect(Register::Input.new.obis).to eq('1-0:1.8.0') }
    end
    context 'when register is output' do
      it { expect(Register::Output.new.obis).to eq('1-0:2.8.0') }
    end
  end

  describe 'low_load_ability' do
    [Register::Base, Register::Real, Register::Input, Register::Output].each do |klass|
      it 'is false' do
        expect(klass.new.low_load_ability).to be(false)
      end
    end
  end

  describe 'pre_decimal_position' do
    [Register::Base, Register::Real, Register::Input, Register::Output].each do |klass|
      it 'is 6' do
        expect(klass.new.pre_decimal_position).to eq(6)
      end
    end
  end

  describe 'post_decimal_position' do
    [Register::Base, Register::Real, Register::Input, Register::Output].each do |klass|
      it 'is 1' do
        expect(klass.new.post_decimal_position).to eq(1)
      end
    end
  end
end
