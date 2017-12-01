# coding: utf-8
describe Register do

  entity!(:urbanstr) do
    Fabricate(:register_urbanstr88, meter: Fabricate(:output_meter))
  end

  entity! :register do
    easymeter_60051560 = Fabricate(:easymeter_60051560)
    easymeter_60051560.broker = Fabricate(:discovergy_broker, meter: easymeter_60051560)
    easymeter_60051560.output_register
  end

  it 'filters register' do
    register = urbanstr

    [register.name].each do |val|
      [val, val.upcase, val.downcase, val[0..4], val[-4..-1]].each do |value|
        registers = Register::Base.filter(value)
        expect(registers).to include register
      end
    end
  end


  it 'can not find anything' do
    registers = Register::Base.filter('Der Clown ist müde und geht nach Hause.')
    expect(registers.size).to eq 0
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

    let(:now) { Time.find_zone('Berlin').local(2016,2,1, 1,30,1) }

    before do
      register.update(observer_enabled: false, observer_offline_monitoring: false)
    end

    it 'creates activities via sidekiq' do
      expect {
        Register::Base.observe
      }.to change(RegisterObserveWorker.jobs, :size).by(1)
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
      now = Time.find_zone('Berlin').local(2016,3,1, 1,30,1)
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

  class Buzzn::Services::ChartsDummy
    def for_register(register, interval)
      return Buzzn::DataResultSet.send(:milliwatt_hour, 'some-id', [Buzzn::DataPoint.new(1491429601.399, 243378558930.2)])
    end
  end

  it 'stores a reading in database' do
    meter = Fabricate(:easymeter_60009405)
    register = meter.registers.first
    register.instance_variable_set('@charts', Buzzn::Services::ChartsDummy.new)
    register.store_reading_at(Time.current.beginning_of_day, Reading::Continuous::REGULAR_READING)
    expect(Reading::Continuous.all.by_register_id(register.id).at(Time.current.beginning_of_day).size).to eq 1
    expect{register.store_reading_at(Time.current.beginning_of_day, Reading::Continuous::REGULAR_READING)}.to raise_error Mongoid::Errors::Validations
    expect(Reading::Continuous.all.by_register_id(register.id).at(Time.current.beginning_of_day).size).to eq 1
    expect{register.store_reading_at(Time.current, Reading::Continuous::REGULAR_READING)}.to raise_error ArgumentError
    expect(Reading::Continuous.all.by_register_id(register.id).at(Time.current.beginning_of_day).size).to eq 1
  end
end
