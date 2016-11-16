# coding: utf-8
describe "Register Model" do

  let(:admin) do
    admin = Fabricate(:user)
    admin.add_role(:admin, nil)
    admin.friends << Fabricate(:user)
    admin
  end

  let(:manager) do
    manager = Fabricate(:user)
    manager.add_role(:manager, urban)
    manager.friends << Fabricate(:user)
    manager
  end

  let(:member) do
    user = Fabricate(:user)
    user.add_role(:member, urban)
    user.friends << Fabricate(:user)
    user
  end

  let(:group) { Fabricate(:group) }
  let(:karin) { Fabricate(:mp_pv_karin) }
  let(:urban) { Fabricate(:mp_urbanstr88) }
  let(:butenland) do
    Fabricate(:mp_hof_butenland_wind,
              readable: :members, group: group)
  end


  it 'filters register', :retry => 3 do
    register = urban

    [register.name, register.address.city,
     register.address.state,
     register.address.street_name].each do |val|
      [val, val.upcase, val.downcase, val[0..4], val[-4..-1]].each do |value|
        registers = Register.filter(value)
        expect(registers.first).to eq register
      end
    end
  end


  it 'can not find anything', :retry => 3 do
    registers = Register.filter('Der Clown ist müde und geht nach Hause.')
    expect(registers.size).to eq 0
  end


  it 'filters register with no params', :retry => 3 do
    registers = Register.filter(nil)
    expect(registers).to match_array Register.all
  end

  describe 'observers' do

    class Crawler
      def self.offline(arg = nil)
        if arg != nil
          @offline = arg
        else
          @offline
        end
      end

      alias :live_orig :live
      def live
        if self.class.offline
          nil
        else
          live_orig
        end
      end
    end

    let(:now) { Time.find_zone('Berlin').local(2016,2,1, 1,30,1) }

    subject do
      Fabricate(:buzzn_metering)
      easymeter_60051560 = Fabricate(:easymeter_60051560)
      easymeter_60051560.registers.first
    end

    before do
      Timecop.freeze(now)
    end

    after do
      Timecop.return
      Crawler.offline(false)
    end

    it 'creates all observer activities' do |spec|
      VCR.use_cassette("models/#{spec.metadata[:description].downcase}") do
        subject.update observe: true, max_watt: 200
        Register.create_all_observer_activities
        expect(PublicActivity::Activity.count).to eq 2
      end
    end

    it 'creates observer activities via sidekiq' do
      expect {
        Register.observe
      }.to change(RegisterObserveWorker.jobs, :size).by(1)
    end

    it 'observe nothing' do |spec|
      VCR.use_cassette("models/#{spec.metadata[:description].downcase}") do
        result = subject.create_observer_activities
        expect(result).to be_nil
      end
    end

    it 'observe exceeds' do |spec|
      VCR.use_cassette("models/#{spec.metadata[:description].downcase}") do
        subject.update observe: true, max_watt: 200
        result = subject.create_observer_activities
        expect(result.key).to eq 'register.exceeds'
      end
    end

    it 'observe undershoots' do |spec|
      VCR.use_cassette("models/#{spec.metadata[:description].downcase}") do
        subject.update observe: true, min_watt: 1000
        result = subject.create_observer_activities
        expect(result.key).to eq 'register.undershoots'
      end
    end

    it 'observe offline' do
      Timecop.return
      now = Time.find_zone('Berlin').local(2016,3,1, 1,30,1)
      Timecop.freeze(now)
      Crawler.offline(true)
      subject.update observe_offline: true, last_observed_timestamp: now.utc
      result = subject.create_observer_activities
      expect(result.key).to eq 'register.offline'

      Timecop.return
      now += 5.minutes
      Timecop.freeze(now)
      result = subject.create_observer_activities
      expect(result).to be_nil
    end
  end

  describe 'permissions' do

    before do
      # get all registers in place
      karin
      urban
      butenland
    end

    it 'restricts readable_by for anonymous users', :retry => 3 do
      expect(Register.readable_by(nil)).to match_array []
      expect(Register.readable_by(nil, :group_inheritance)).to match_array [butenland]
      urban.update!(readable: 'world')
      [:members, :friends, :community].each do |readable|
        karin.update!(readable: readable)
        expect(Register.readable_by(nil)).to match_array [urban]
        expect(Register.readable_by(nil, :group_inheritance)).to match_array [urban, butenland]
      end
      karin.update!(readable: 'world')
      expect(Register.readable_by(nil)).to match_array [karin, urban]
      expect(Register.readable_by(nil, :group_inheritance)).to match_array [karin, urban, butenland]
    end


    it 'restricts readable_by for community users', :retry => 3 do
      user = Fabricate(:user)
      expect(Register.readable_by(user)).to match_array []
      urban.update!(readable: 'community')
      [:members, :friends].each do |readable|
        karin.update!(readable: readable)
        expect(Register.readable_by(user)).to match_array [urban]
        expect(Register.readable_by(user, :group_inheritance)).to match_array [urban, butenland]
      end
      karin.update!(readable: 'community')
      expect(Register.readable_by(user)).to match_array [karin, urban]
      expect(Register.readable_by(user, :group_inheritance)).to match_array [karin, urban, butenland]
    end


    it 'restricts readable_by for register members or manager', :retry => 3 do
      expect(Register.readable_by(member)).to match_array [urban]
      expect(Register.readable_by(member, :group_inheritance)).to match_array [urban, butenland]
      expect(Register.readable_by(manager)).to match_array [urban]
      expect(Register.readable_by(manager, :group_inheritance)).to match_array [urban, butenland]
    end


    it 'restricts readable_by for register for friends of manager', :retry => 3 do
      expect(Register.readable_by(member.friends.first)).to match_array []
      expect(Register.readable_by(member.friends.first, :group_inheritance)).to match_array [butenland]
      expect(Register.readable_by(admin.friends.first)).to eq []
      expect(Register.readable_by(admin.friends.first, :group_inheritance)).to eq [butenland]
      expect(Register.readable_by(manager.friends.first)).to match_array [urban]
      expect(Register.readable_by(manager.friends.first, :group_inheritance)).to match_array [urban, butenland]
      urban.update! readable: :members
      expect(Register.readable_by(manager.friends.first)).to eq []
      expect(Register.readable_by(manager.friends.first, :group_inheritance)).to eq [butenland]
      expect(Register.readable_by(member.friends.first)).to eq []
      expect(Register.readable_by(member.friends.first, :group_inheritance)).to eq [butenland]
      expect(Register.readable_by(admin.friends.first)).to eq []
      expect(Register.readable_by(admin.friends.first, :group_inheritance)).to eq [butenland]
    end


    it 'restricts readable_by for register belonging to readable group', :retry => 3 do
      expect(Register.readable_by(member.friends.first)).to match_array []
      expect(Register.readable_by(member.friends.first, :group_inheritance)).to match_array [butenland]
      expect(Register.readable_by(admin.friends.first)).to eq []

      expect(Register.readable_by(admin.friends.first, :group_inheritance)).to eq [butenland]
      expect(Register.readable_by(manager.friends.first)).to match_array [urban]
      expect(Register.readable_by(manager.friends.first, :group_inheritance)).to match_array [urban, butenland]
      expect(Register.readable_by(nil)).to match_array []
      expect(Register.readable_by(nil, :group_inheritance)).to match_array [butenland]

      butenland.group.update! readable: :members
      expect(Register.readable_by(manager.friends.first)).to eq [urban]
      expect(Register.readable_by(member.friends.first)).to eq []
      expect(Register.readable_by(admin.friends.first)).to eq []
      expect(Register.readable_by(nil)).to eq []
    end


    it 'does not restrict readable_by for admins', :retry => 3 do
      expect(Register.readable_by(admin)).to match_array Register.all
    end

    it 'anonymizes the name when MP is not readable without group inhereted readablity', :retry => 3 do
      user = Fabricate(:user)
      [nil, user, member, member.friends.first, manager, manager.friends.first].each do |u|
        expect(
          Register.by_group(group).anonymized(u).collect{ |mp| mp.name }
        ).to eq ['anonymous']
      end

      urban.update! group: group
      [nil, user, member.friends.first].each do |u|
        expect(
          Register.by_group(group).anonymized(u).collect{ |mp| mp.name }
        ).to eq ['anonymous', 'anonymous']
      end
      [member, manager, manager.friends.first].each do |u|
        expect(
          Register.by_group(group).anonymized(u).collect{ |mp| mp.name }
        ).to match_array ['Wohnung', 'anonymous']
      end

      karin.update! group: group
      [nil, user, member.friends.first].each do |u|
        expect(
          Register.by_group(group).anonymized(u).collect{ |mp| mp.name }
        ).to match_array ['anonymous', 'anonymous', 'anonymous']
      end
      [member, manager, manager.friends.first].each do |u|
        expect(
          Register.by_group(group).anonymized(u).collect{ |mp| mp.name }
        ).to match_array ['Wohnung', 'anonymous', 'anonymous']
      end

      butenland.update! readable: 'world'
      [nil, user, member.friends.first].each do |u|
        expect(
          Register.by_group(group).anonymized(u).collect{ |mp| mp.name }
        ).to match_array ['Windanlage', 'anonymous', 'anonymous']
      end
      [member, manager, manager.friends.first].each do |u|
        expect(
          Register.by_group(group).anonymized(u).collect{ |mp| mp.name }
        ).to match_array ['Wohnung', 'Windanlage', 'anonymous']
      end
    end
  end
end
