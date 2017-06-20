# coding: utf-8
# need to load as we overwrite validate_credentials method
require './app/models/broker/discovergy'
describe "Register Model" do

  entity!(:group) { Fabricate(:tribe) }
  entity!(:karin) { Fabricate(:register_pv_karin, meter: Fabricate(:meter)) }
  entity!(:urbanstr) do
    Fabricate(:register_urbanstr88, meter: Fabricate(:meter))
  end
  entity!(:butenland) do
    Fabricate(:register_hof_butenland_wind, meter: Fabricate(:meter), readable: :members, group: group)
  end
  entity(:tribe) { butenland.group }

  entity(:admin) do
    admin = Fabricate(:admin)
    admin.friends << Fabricate(:user)
    admin
  end

  entity(:manager) do
    manager = Fabricate(:user)
    manager.add_role(:manager, urbanstr)
    manager.friends << Fabricate(:user)
    manager
  end

  entity(:member) do
    user = Fabricate(:user)
    user.add_role(:member, urbanstr)
    user.friends << Fabricate(:user)
    user
  end

  entity! :easymeter do
    easymeter_60051560 = Fabricate(:easymeter_60051560)
    easymeter_60051560.broker = Fabricate(:discovergy_broker, mode: 'out', external_id: "EASYMETER_60051560", resource: easymeter_60051560)
    easymeter_60051560.output_register
  end

  before do
    tribe.update!(readable: 'world')
    urbanstr.update!(readable: 'friends', group: nil)
    karin.update!(readable: 'friends', group: nil)
    butenland.update!(readable: 'members', group: tribe)
  end

  it 'filters register' do
    register = urbanstr

    [register.name, register.address.city,
     register.address.state,
     register.address.street_name].each do |val|
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
    consumption = Register::Base.all.by_label(Register::Base::CONSUMPTION).size
    production = Register::Base.all.by_label(Register::Base::PRODUCTION_PV).size
    3.times do
      Fabricate(:input_meter)
    end
    3.times do
      Fabricate(:output_meter)
    end
    expect(Register::Base.all.by_label(Register::Base::CONSUMPTION).size).to eq consumption + 3
    expect(Register::Base.all.by_label(Register::Base::PRODUCTION_PV).size).to eq production + 3
    expect(Register::Base.all.by_label(Register::Base::CONSUMPTION, Register::Base::PRODUCTION_PV).size).to eq consumption + production + 6
    expect(Register::Base.all.by_label(Register::Base::GRID_FEEDING, Register::Base::DEMARCATION_PV).size).to eq 0
    expect {Register::Base.all.by_label('not_working') }.to raise_error ArgumentError
  end





  describe 'observers' do

    let(:now) { Time.find_zone('Berlin').local(2016,2,1, 1,30,1) }

    before do
      easymeter.update(observe: false, observe_offline: false)
      Timecop.freeze(now)
    end

    after do
      Timecop.return
    end

    it 'creates all observer activities' do |spec|
      VCR.use_cassette("models/#{spec.metadata[:description].downcase}") do
        easymeter.update! observe: true, max_watt: 200, min_watt: 0
        #count = PublicActivity::Activity.count
        Register::Base.create_all_observer_activities
        #expect(PublicActivity::Activity.count).to eq count + 1
      end
    end

    it 'creates observer activities via sidekiq' do
      expect {
        Register::Base.observe
      }.to change(RegisterObserveWorker.jobs, :size).by(1)
    end

    it 'observe nothing' do |spec|
      VCR.use_cassette("models/#{spec.metadata[:description].downcase}") do
        easymeter.update observe: false
        result = easymeter.create_observer_activities
        expect(result).to be_nil
      end
    end

    it 'observe exceeds' do |spec|
      VCR.use_cassette("models/#{spec.metadata[:description].downcase}") do
        easymeter.update observe: true, max_watt: 200, min_watt: 0
        result = easymeter.create_observer_activities
        #expect(result.key).to eq 'register.exceeds'
      end
    end

    it 'observe undershoots' do |spec|
      VCR.use_cassette("models/#{spec.metadata[:description].downcase}") do
        easymeter.update observe: true, min_watt: 1000, max_watt: 2000
        result = easymeter.create_observer_activities
        #expect(result.key).to eq 'register.undershoots'
      end
    end

    it 'observe offline', retry: 3 do |spec|
      now = Time.find_zone('Berlin').local(2016,3,1, 1,30,1)
      VCR.use_cassette("models/#{spec.metadata[:description].downcase}_first") do
        Timecop.return
        Timecop.freeze(now)
        easymeter.update observe_offline: true, last_observed_timestamp: now.utc
        result = easymeter.create_observer_activities
        expect(result).to be_nil
      end
      VCR.use_cassette("models/#{spec.metadata[:description].downcase}_second") do
        Timecop.return
        now += 5.minutes
        Timecop.freeze(now)
        result = easymeter.create_observer_activities
        #expect(result.key).to eq 'register.offline'
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
    register.store_reading_at(Time.current.beginning_of_day, Reading::REGULAR_READING)
    expect(Reading.all.by_register_id(register.id).at(Time.current.beginning_of_day).size).to eq 1
    expect{register.store_reading_at(Time.current.beginning_of_day, Reading::REGULAR_READING)}.to raise_error Mongoid::Errors::Validations
    expect(Reading.all.by_register_id(register.id).at(Time.current.beginning_of_day).size).to eq 1
    expect{register.store_reading_at(Time.current, Reading::REGULAR_READING)}.to raise_error ArgumentError
    expect(Reading.all.by_register_id(register.id).at(Time.current.beginning_of_day).size).to eq 1
  end
end
