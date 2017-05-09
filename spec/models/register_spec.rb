# coding: utf-8
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
        count = PublicActivity::Activity.count
        Register::Base.create_all_observer_activities
        expect(PublicActivity::Activity.count).to eq count + 1
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
        expect(result.key).to eq 'register.exceeds'
      end
    end

    it 'observe undershoots' do |spec|
      VCR.use_cassette("models/#{spec.metadata[:description].downcase}") do
        easymeter.update observe: true, min_watt: 1000, max_watt: 2000
        result = easymeter.create_observer_activities
        expect(result.key).to eq 'register.undershoots'
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
        expect(result.key).to eq 'register.offline'
      end
    end
  end

  describe 'permissions' do

    it 'restricts readable_by for anonymous users' do
      expect(Register::Base.readable_by(nil, false)).to match_array [easymeter]
      expect(Register::Base.readable_by(nil, true)).to match_array [easymeter, butenland]
      expect(butenland.readable_by?(nil)).to be false
      expect(butenland.readable_by?(nil, :group_inheritance)).to be true

      urbanstr.update!(readable: 'world')
      expect(urbanstr.readable_by?(nil)).to be true
      expect(urbanstr.readable_by?(nil, :group_inheritance)).to be true
      [:members, :friends, :community].each do |readable|
        karin.update!(readable: readable)
        expect(Register::Base.readable_by(nil, false)).to match_array [easymeter, urbanstr]
        expect(Register::Base.readable_by(nil, true)).to match_array [easymeter, urbanstr, butenland]
      end
      karin.update!(readable: 'world')
      expect(Register::Base.readable_by(nil, false)).to match_array [easymeter, karin, urbanstr]
      expect(Register::Base.readable_by(nil, true)).to match_array [easymeter, karin, urbanstr, butenland]
    end


    it 'restricts readable_by for community users' do
      user = Fabricate(:user)
      expect(Register::Base.readable_by(user, false)).to match_array [easymeter]
      urbanstr.update!(readable: 'community')
      expect(urbanstr.readable_by?(user)).to be true
      expect(urbanstr.readable_by?(user, :group_inheritance)).to be true
      expect(butenland.readable_by?(user)).to be false
      expect(butenland.readable_by?(user, :group_inheritance)).to be true
      [:members, :friends].each do |readable|
        karin.update!(readable: readable)
        expect(Register::Base.readable_by(user, false)).to match_array [easymeter, urbanstr]
        expect(Register::Base.readable_by(user, true)).to match_array [easymeter, urbanstr, butenland]
      end
      karin.update!(readable: 'community')
      expect(Register::Base.readable_by(user, false)).to match_array [easymeter, karin, urbanstr]
      expect(Register::Base.readable_by(user, true)).to match_array [easymeter, karin, urbanstr, butenland]
    end


    it 'restricts readable_by for register members or manager' do
      [manager, member].each do |user|
        expect(Register::Base.readable_by(user, false)).to match_array [easymeter, urbanstr]
        expect(Register::Base.readable_by(user, true)).to match_array [easymeter, urbanstr, butenland]
        expect(urbanstr.readable_by?(user)).to be true
        expect(urbanstr.readable_by?(user, :group_inheritance)).to be true
        expect(butenland.readable_by?(user)).to be false
        expect(butenland.readable_by?(user, :group_inheritance)).to be true
      end
    end


    it 'restricts readable_by for register for friends of manager' do
      [member.friends.first, admin.friends.first].each do |user|
        expect(Register::Base.readable_by(user, false)).to match_array [easymeter]
        expect(Register::Base.readable_by(user, true)).to match_array [easymeter, butenland]
        expect(urbanstr.readable_by?(user)).to be false
        expect(urbanstr.readable_by?(user, :group_inheritance)).to be false
        expect(butenland.readable_by?(user)).to be false
        expect(butenland.readable_by?(user, :group_inheritance)).to be true
      end
      expect(Register::Base.readable_by(manager.friends.first, false)).to match_array [easymeter, urbanstr]
      expect(Register::Base.readable_by(manager.friends.first, true)).to match_array [easymeter, urbanstr, butenland]
      user = manager.friends.first
      expect(Register::Base.readable_by(user, false)).to match_array [easymeter, urbanstr]
      expect(Register::Base.readable_by(user, true)).to match_array [easymeter, urbanstr, butenland]
      expect(urbanstr.readable_by?(user)).to be true
      expect(urbanstr.readable_by?(user, :group_inheritance)).to be true

      urbanstr.update! readable: :members
      expect(urbanstr.readable_by?(user)).to be false
      expect(urbanstr.readable_by?(user, :group_inheritance)).to be false
      [member.friends.first, manager.friends.first, admin.friends.first].each do |user|
        expect(Register::Base.readable_by(user, false)).to eq [easymeter]
        expect(Register::Base.readable_by(user, true)).to match_array [easymeter, butenland]
      end
    end


    it 'restricts readable_by for register belonging to readable group' do
      [nil, member.friends.first, admin.friends.first].each do |user|
        expect(Register::Base.readable_by(user, false)).to match_array [easymeter]
        expect(Register::Base.readable_by(user, true)).to match_array [easymeter, butenland]
      end

      expect(Register::Base.readable_by(manager.friends.first, false)).to match_array [easymeter, urbanstr]
      expect(Register::Base.readable_by(manager.friends.first, true)).to match_array [easymeter, urbanstr, butenland]

      butenland.group.update! readable: :members
      expect(Register::Base.readable_by(manager.friends.first, false)).to match_array [easymeter, urbanstr]
      [nil, member.friends.first, admin.friends.first].each do |user|
        expect(Register::Base.readable_by(user, false)).to eq [easymeter]
        [urbanstr, butenland, karin].each do |register|
          expect(register.readable_by?(user)).to be false
          expect(register.readable_by?(user, :group_inheritance)).to be false
        end
      end
    end

    it 'does not restrict readable_by for admins' do
      expect(Register::Base.readable_by(admin, false)).to match_array Register::Base.all
      expect(Register::Base.readable_by(admin, true)).to match_array Register::Base.all
      expect(Register::Base.first.readable_by?(admin)).to be true
      expect(Register::Base.first.readable_by?(admin, :group_inheritance)).to be true
    end

    it 'anonymizes the name when register is not readable without group inhereted readablity' do
      user = Fabricate(:user)
      [nil, user, member, member.friends.first, manager, manager.friends.first].each do |u|
        expect(
          Register::Base.by_group(group).anonymized(u).collect{ |r| r.name }
        ).to eq ['anonymous']
      end

      urbanstr.update! group: group
      [nil, user, member.friends.first].each do |u|
        expect(
          Register::Base.by_group(group).anonymized(u).collect{ |mp| mp.name }
        ).to eq ['anonymous', 'anonymous']
      end
      [member, manager, manager.friends.first].each do |u|
        expect(
          Register::Base.by_group(group).anonymized(u).collect{ |mp| mp.name }
        ).to match_array ['Wohnung', 'anonymous']
      end

      karin.update! group: group
      [nil, user, member.friends.first].each do |u|
        expect(
          Register::Base.by_group(group).anonymized(u).collect{ |mp| mp.name }
        ).to match_array ['anonymous', 'anonymous', 'anonymous']
      end
      [member, manager, manager.friends.first].each do |u|
        expect(
          Register::Base.by_group(group).anonymized(u).collect{ |mp| mp.name }
        ).to match_array ['Wohnung', 'anonymous', 'anonymous']
      end

      butenland.update! readable: 'world'
      [nil, user, member.friends.first].each do |u|
        expect(
          Register::Base.by_group(group).anonymized(u).collect{ |mp| mp.name }
        ).to match_array ['Windanlage', 'anonymous', 'anonymous']
      end
      [member, manager, manager.friends.first].each do |u|
        expect(
          Register::Base.by_group(group).anonymized(u).collect{ |mp| mp.name }
        ).to match_array ['Wohnung', 'Windanlage', 'anonymous']
      end
    end
  end

  class Broker::Discovergy
    def validates_credentials
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
