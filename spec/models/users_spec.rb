# coding: utf-8
describe "User Model" do

  it 'filters user with given firstname' do
    user = Fabricate(:user)
    2.times { Fabricate(:user) }

    [user.first_name, user.first_name.upcase, user.first_name.downcase, user.first_name[0..3], user.first_name[-3..-1]].each do |first|
      users = User.filter(first_name: first)
      break if users.size > 1
      expect(users.first).to eq user
    end

    users = User.filter(first_name: 'Hans-Jürgen-Klaus')
    expect(users.size).to eq 0
  end

  it 'filters user with given lastname' do
    user = Fabricate(:user)
    2.times { Fabricate(:user) }

    [user.last_name, user.last_name.upcase, user.last_name.downcase, user.last_name[0..2], user.last_name[-2..-1]].each do |last|
      users = User.filter(last_name: last)
      break if users.size > 1
      expect(users.last).to eq user
    end

    users = User.filter(last_name: 'Schleier-Helwig-Holzhammer')
    expect(users.size).to eq 0
  end

  it 'filters users which belongs to a group' do
    group = Fabricate(:group_karins_pv_strom)
    metering_point = Fabricate(:mp_pv_karin)
    member = Fabricate(:user)
    member.add_role(:member, metering_point)
    manager = Fabricate(:user)
    manager.add_role(:manager, group)
    group.metering_points << metering_point
    group.save

    ['PV', 'pv'].each do |name|
      users = User.filter(group_name: name)
      expect(users.collect).to  match_array([member, manager])
    end

    users = User.filter(group_name: 'Dark side of the Moon')
    expect(users.size).to eq 0
  end

  it 'filters user by last_name and group' do
    group = Fabricate(:group_karins_pv_strom)
    metering_point = Fabricate(:mp_pv_karin)
    member = Fabricate(:user)
    member.add_role(:member, metering_point)
    manager = Fabricate(:user)
    manager.add_role(:manager, group)
    group.metering_points << metering_point
    group.save
    2.times { Fabricate(:user) }

    users = User.filter(first_name: member.last_name, group_name: group.name)
    expect(users.size).to eq 2
    expect(users.collect).to  match_array([member, manager])

    user = Fabricate(:user)
    users = User.filter(last_name: user.last_name, group_name: group.name)
    expect(users.size).to eq 3
    expect(users.collect).to  match_array([member, manager, user])
  end

  it 'filters user by first_name and group' do
    group = Fabricate(:group_karins_pv_strom)
    metering_point = Fabricate(:mp_pv_karin)
    member = Fabricate(:user)
    member.add_role(:member, metering_point)
    manager = Fabricate(:user)
    manager.add_role(:manager, group)
    group.metering_points << metering_point
    group.save
    2.times { Fabricate(:user) }

    users = User.filter(first_name: manager.first_name, group_name: group.name)
    expect(users.size).to eq 2
    expect(users.collect).to  match_array([member, manager])

    user = Fabricate(:user)
    users = User.filter(first_name: user.first_name, group_name: group.name)
    expect(users.size).to eq 3
    expect(users.collect).to  match_array([member, manager, user])
  end

  it 'filters user by last_name and first_name' do
    user1 = Fabricate(:user)
    user2 = Fabricate(:user)
    2.times { Fabricate(:user) }

    users = User.filter(last_name: user1.last_name,
                        first_name: user2.first_name)
    expect(users.size).to eq 2
    expect(users.collect).to  match_array([user1, user2])
  end
  it 'filters user with no params' do
    5.times { Fabricate(:user) }

    users = User.filter({})
    expect(users.size).to eq 5
  end
end
