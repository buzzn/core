# coding: utf-8
describe "Group Model" do

  it 'filters group', :retry => 3 do
    group = Fabricate(:group_home_of_the_brave)
    Fabricate(:group_karins_pv_strom)

    [group.name, group.description].each do |val|
      [val, val.upcase, val.downcase, val[0..4], val[-4..-1]].each do |value|
        groups = Group::Base.filter(value)
        expect(groups.first).to eq group
      end
    end
  end


  it 'can not find anything' do
    Fabricate(:group_hof_butenland)
    groups = Group::Base.filter('Der Clown ist müde und geht nach Hause.')
    expect(groups.size).to eq 0
  end


  it 'filters group with no params' do
    Fabricate(:group_wagnis4)
    Fabricate(:group_hof_butenland)
    Fabricate(:group_karins_pv_strom)

    groups = Group::Base.filter(nil)
    expect(groups.size).to eq 3
  end

  it 'limits readable_by' do
    wagnis4   = Fabricate(:group_wagnis4, readable: 'world')
    butenland = Fabricate(:group_hof_butenland, readable: 'community')
    karin     = Fabricate(:group_karins_pv_strom, readable: 'friends')
    group     = Fabricate(:group_with_members_readable_by_world, readable: 'members')
    guest     = nil
    manager   = Fabricate(:user)
    manager.add_role(:manager, karin)

    expect(Group::Base.readable_by(guest)).to eq [wagnis4]
    user = Fabricate(:user)
    expect(Group::Base.readable_by(user)).to match_array [wagnis4, butenland]

    user.add_role(:admin, guest)
    expect(Group::Base.readable_by(user)).to match_array [wagnis4, butenland, group, karin]

    expect(Group::Base.readable_by(group.members.first)).to match_array [wagnis4, butenland, group]
    expect(Group::Base.readable_by(karin.managers.first)).to match_array [wagnis4, butenland, karin]

    manager.friends << Fabricate(:user)
    expect(Group::Base.readable_by(karin.managers.first.friends.first)).to match_array [wagnis4, butenland, karin]

    manager.add_role(:manager, group)
    expect(Group::Base.readable_by(group.managers.first.friends.first)).to match_array [wagnis4, butenland, karin]

    friend = Fabricate(:user)
    group.members.first.friends << friend
    expect(Group::Base.readable_by(friend)).to match_array [wagnis4, butenland]
  end

  it 'selects the energy producers/consumers and involved users of a group' do
    group         = Fabricate(:group)
    user          = Fabricate(:user)
    consumer      = Fabricate(:user)
    producer      = Fabricate(:user)
    register_in   = Fabricate(:input_register, meter: Fabricate(:meter))
    register_out  = Fabricate(:output_register, meter: Fabricate(:meter))

    group.registers += [register_in, register_out]

    expect(group.energy_producers).to match_array []
    expect(group.energy_consumers).to match_array []
    expect(group.involved).to match_array []

    producer.add_role(:manager, register_out)
    expect(group.energy_producers).to match_array [producer]
    expect(group.energy_consumers).to match_array []
    expect(group.involved).to match_array [producer]

    consumer.add_role(:member, register_in)
    expect(group.energy_producers).to match_array [producer]
    expect(group.energy_consumers).to match_array [consumer]
    expect(group.involved).to match_array [producer, consumer]

    consumer.add_role(:member, register_out)
    producer.add_role(:member, register_in)
    expect(group.energy_producers).to match_array [producer, consumer]
    expect(group.energy_consumers).to match_array [consumer, producer]
    expect(group.involved).to match_array [producer, consumer]

    user.add_role(:member, register_out)
    expect(group.energy_producers).to match_array [user, producer, consumer]
    expect(group.energy_consumers).to match_array [consumer, producer]
    expect(group.involved).to match_array [producer, consumer, user]

    user.add_role(:manager, register_in)
    expect(group.energy_producers).to match_array [user, producer, consumer]
    expect(group.energy_consumers).to match_array [user, consumer, producer]
    expect(group.involved).to match_array [producer, consumer, user]
  end

  it 'calculates its scores on given group' do
    group = Fabricate(:group)
    group.calculate_scores(Time.find_zone('Berlin').local(2016,2,2, 1,30,1))

    expect(Score.count).to eq 12
  end

  it 'calculates scores of all groups via sidekiq' do
    expect {
      Group::Base.calculate_scores
    }.to change(CalculateGroupScoresWorker.jobs, :size).by(1)
  end
end
