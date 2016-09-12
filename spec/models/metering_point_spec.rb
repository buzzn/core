# coding: utf-8
describe "MeteringPoint Model" do
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

  before do
    # get all metering_points in place
    karin
    urban
    butenland
  end


  it 'filters metering_point' do
    metering_point = urban

    [metering_point.name, metering_point.address.city,
     metering_point.address.state,
     metering_point.address.street_name].each do |val|
      [val, val.upcase, val.downcase, val[0..4], val[-4..-1]].each do |value|
        metering_points = MeteringPoint.filter(value)
        expect(metering_points.first).to eq metering_point
      end
    end
  end


  it 'can not find anything' do
    metering_points = MeteringPoint.filter('Der Clown ist müde und geht nach Hause.')
    expect(metering_points.size).to eq 0
  end


  it 'filters metering_point with no params' do
    metering_points = MeteringPoint.filter(nil)
    expect(metering_points).to match_array MeteringPoint.all
  end


  it 'restricts readable_by for anonymous users' do
    expect(MeteringPoint.readable_by(nil)).to match_array []
    expect(MeteringPoint.readable_by(nil, :group_inheritance)).to match_array [butenland]
    urban.update!(readable: 'world')
    [:members, :friends, :community].each do |readable|
      karin.update!(readable: readable)
      expect(MeteringPoint.readable_by(nil)).to match_array [urban]
      expect(MeteringPoint.readable_by(nil, :group_inheritance)).to match_array [urban, butenland]
    end
    karin.update!(readable: 'world')
    expect(MeteringPoint.readable_by(nil)).to match_array [karin, urban]
    expect(MeteringPoint.readable_by(nil, :group_inheritance)).to match_array [karin, urban, butenland]
  end


  it 'restricts readable_by for community users' do
    user = Fabricate(:user)
    expect(MeteringPoint.readable_by(user)).to match_array []
    urban.update!(readable: 'community')
    [:members, :friends].each do |readable|
      karin.update!(readable: readable)
      expect(MeteringPoint.readable_by(user)).to match_array [urban]
      expect(MeteringPoint.readable_by(user, :group_inheritance)).to match_array [urban, butenland]
    end
    karin.update!(readable: 'community')
    expect(MeteringPoint.readable_by(user)).to match_array [karin, urban]
    expect(MeteringPoint.readable_by(user, :group_inheritance)).to match_array [karin, urban, butenland]
  end


  it 'restricts readable_by for metering_point members or manager' do
    expect(MeteringPoint.readable_by(member)).to match_array [urban]
    expect(MeteringPoint.readable_by(member, :group_inheritance)).to match_array [urban, butenland]
    expect(MeteringPoint.readable_by(manager)).to match_array [urban]
    expect(MeteringPoint.readable_by(manager, :group_inheritance)).to match_array [urban, butenland]
  end


  it 'restricts readable_by for metering_point for friends of manager' do
    expect(MeteringPoint.readable_by(member.friends.first)).to match_array []
    expect(MeteringPoint.readable_by(member.friends.first, :group_inheritance)).to match_array [butenland]
    expect(MeteringPoint.readable_by(admin.friends.first)).to eq []
    expect(MeteringPoint.readable_by(admin.friends.first, :group_inheritance)).to eq [butenland]
    expect(MeteringPoint.readable_by(manager.friends.first)).to match_array [urban]
    expect(MeteringPoint.readable_by(manager.friends.first, :group_inheritance)).to match_array [urban, butenland]
    urban.update! readable: :members
    expect(MeteringPoint.readable_by(manager.friends.first)).to eq []
    expect(MeteringPoint.readable_by(manager.friends.first, :group_inheritance)).to eq [butenland]
    expect(MeteringPoint.readable_by(member.friends.first)).to eq []
    expect(MeteringPoint.readable_by(member.friends.first, :group_inheritance)).to eq [butenland]
    expect(MeteringPoint.readable_by(admin.friends.first)).to eq []
    expect(MeteringPoint.readable_by(admin.friends.first, :group_inheritance)).to eq [butenland]
  end


  it 'restricts readable_by for metering_point belonging to readable group' do
    expect(MeteringPoint.readable_by(member.friends.first)).to match_array []
    expect(MeteringPoint.readable_by(member.friends.first, :group_inheritance)).to match_array [butenland]
    expect(MeteringPoint.readable_by(admin.friends.first)).to eq []
    
    expect(MeteringPoint.readable_by(admin.friends.first, :group_inheritance)).to eq [butenland]
    expect(MeteringPoint.readable_by(manager.friends.first)).to match_array [urban]
    expect(MeteringPoint.readable_by(manager.friends.first, :group_inheritance)).to match_array [urban, butenland]
    expect(MeteringPoint.readable_by(nil)).to match_array []
    expect(MeteringPoint.readable_by(nil, :group_inheritance)).to match_array [butenland]

    butenland.group.update! readable: :members
    expect(MeteringPoint.readable_by(manager.friends.first)).to eq [urban]
    expect(MeteringPoint.readable_by(member.friends.first)).to eq []
    expect(MeteringPoint.readable_by(admin.friends.first)).to eq []
    expect(MeteringPoint.readable_by(nil)).to eq []
  end


  it 'does not restrict readable_by for admins' do
    expect(MeteringPoint.readable_by(admin)).to match_array MeteringPoint.all
  end

  it 'anonymizes the name when MP is not readable without group inhereted readablity' do
    user = Fabricate(:user)
    [nil, user, member, member.friends.first, manager, manager.friends.first].each do |u|
      expect(
        MeteringPoint.by_group(group).anonymized(u).collect{ |mp| mp.name }
      ).to eq ['anonymous']
    end

    urban.update! group: group
    [nil, user, member.friends.first].each do |u|
      expect(
        MeteringPoint.by_group(group).anonymized(u).collect{ |mp| mp.name }
      ).to eq ['anonymous', 'anonymous']
    end
    [member, manager, manager.friends.first].each do |u|
      expect(
        MeteringPoint.by_group(group).anonymized(u).collect{ |mp| mp.name }
      ).to match_array ['Wohnung', 'anonymous']
    end

    karin.update! group: group
    [nil, user, member.friends.first].each do |u|
      expect(
        MeteringPoint.by_group(group).anonymized(u).collect{ |mp| mp.name }
      ).to match_array ['anonymous', 'anonymous', 'anonymous']
    end
    [member, manager, manager.friends.first].each do |u|
      expect(
        MeteringPoint.by_group(group).anonymized(u).collect{ |mp| mp.name }
      ).to match_array ['Wohnung', 'anonymous', 'anonymous']
    end

    butenland.update! readable: 'world'
    [nil, user, member.friends.first].each do |u|
      expect(
        MeteringPoint.by_group(group).anonymized(u).collect{ |mp| mp.name }
      ).to match_array ['Windanlage', 'anonymous', 'anonymous']
    end
    [member, manager, manager.friends.first].each do |u|
      expect(
        MeteringPoint.by_group(group).anonymized(u).collect{ |mp| mp.name }
      ).to match_array ['Wohnung', 'Windanlage', 'anonymous']
    end
  end
end
