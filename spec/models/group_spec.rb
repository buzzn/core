# coding: utf-8
describe "Group Model" do

  it 'filters group' do
    Fabricate(:buzzn_metering)
    group = Fabricate(:group_home_of_the_brave)
    Fabricate(:group_karins_pv_strom)

    [group.name, group.description].each do |val|
      [val, val.upcase, val.downcase, val[0..4], val[-4..-1]].each do |value|
        groups = Group.filter(value)
        expect(groups.first).to eq group
      end
    end
  end


  it 'can not find anything' do
    Fabricate(:buzzn_metering)
    Fabricate(:group_hof_butenland)
    groups = Group.filter('Der Clown ist müde und geht nach Hause.')
    expect(groups.size).to eq 0
  end


  it 'filters group with no params' do
    Fabricate(:buzzn_metering)
    Fabricate(:group_wagnis4)
    Fabricate(:group_hof_butenland)
    Fabricate(:group_karins_pv_strom)

    groups = Group.filter(nil)
    expect(groups.size).to eq 3
  end

  it 'limits readable_by' do
    Fabricate(:buzzn_metering)
    wagnis4 = Fabricate(:group_wagnis4, readable: 'world')
    butenland = Fabricate(:group_hof_butenland, readable: 'community')
    karin = Fabricate(:group_karins_pv_strom, readable: 'friends')
    group = Fabricate(:group_with_members_readable_by_world, readable: 'members')
    manager = Fabricate(:user)
    manager.add_role(:manager, karin)

    expect(Group.readable_by(nil).collect{|c| c}).to eq [wagnis4]
    user = Fabricate(:user)
    expect(Group.readable_by(user).collect{|c| c}).to match_array [wagnis4, butenland]

    user.add_role(:admin, nil)
    expect(Group.readable_by(user).collect{|c| c }).to match_array [wagnis4, butenland, group, karin]

    expect(Group.readable_by(group.members.first).collect{|c| c }).to match_array [wagnis4, butenland, group]
    expect(Group.readable_by(karin.managers.first).collect{|c| c }).to match_array [wagnis4, butenland, karin]

    manager.friends << Fabricate(:user)
    expect(Group.readable_by(karin.managers.first.friends.first).collect{|c| c }).to match_array [wagnis4, butenland, karin]

    manager.add_role(:manager, group)
    expect(Group.readable_by(group.managers.first.friends.first).collect{|c| c }).to match_array [wagnis4, butenland, karin]
    
    friend = Fabricate(:user)
    group.members.first.friends << friend
    expect(Group.readable_by(friend).collect{|c| c }).to match_array [wagnis4, butenland]
  end

  it 'selects the energy producers/consumers of a group' do
    group         = Fabricate(:group)
    user          = Fabricate(:user)
    consumer      = Fabricate(:user)
    producer      = Fabricate(:user)
    mp_in         = Fabricate(:metering_point, mode: 'in')
    mp_out        = Fabricate(:metering_point, mode: 'out')

    group.metering_points += [mp_in, mp_out]

    expect(group.energy_producers).to match_array []
    expect(group.energy_consumers).to match_array []

    producer.add_role(:manager, mp_in)
    expect(group.energy_producers).to match_array [producer]
    expect(group.energy_consumers).to match_array []

    consumer.add_role(:member, mp_out)
    expect(group.energy_producers).to match_array [producer]
    expect(group.energy_consumers).to match_array [consumer]
    
    consumer.add_role(:member, mp_in)
    producer.add_role(:member, mp_out)
    expect(group.energy_producers).to match_array [producer, consumer]
    expect(group.energy_consumers).to match_array [consumer, producer]
    
    user.add_role(:member, mp_in)
    expect(group.energy_producers).to match_array [user, producer, consumer]
    expect(group.energy_consumers).to match_array [consumer, producer]

    user.add_role(:manager, mp_out)
    expect(group.energy_producers).to match_array [user, producer, consumer]
    expect(group.energy_consumers).to match_array [user, consumer, producer]
  end
end
