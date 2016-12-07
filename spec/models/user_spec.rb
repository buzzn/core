# coding: utf-8
describe "User Model" do

  let(:organization) { Fabricate(:organization, mode: :electricity_supplier) }
  let(:group) do
    g = Fabricate(:group)
    manager_group.add_role(:manager, g)
    g
  end
  let(:register) do
    register = Fabricate(:output_register, meter: Fabricate(:meter))
    manager_register.add_role(:manager, register)
    register.update! group: group
    register
  end
  let(:user) { Fabricate(:user) }
  let(:manager_register) { Fabricate(:user) }
  let(:manager_group) { Fabricate(:user) }
                            
  it 'filters user with given email', :retry => 3 do
    user = Fabricate(:user)
    2.times { Fabricate(:user) }

    [user.email, user.email.upcase, user.email.downcase, user.email[0..3], user.email[-3..-1]].each do |first|
      users = User.send(:do_filter, first, :email)
      break if users.size > 1
      expect(users.first).to eq user
    end

    users = User.send(:do_filter, 'haJürK@example.xom', :email)
    expect(users.size).to eq 0
  end

  it 'filters user with given firstname', :retry => 3 do
    user = Fabricate(:user)
    2.times { Fabricate(:user) }

    [user.first_name, user.first_name.upcase, user.first_name.downcase, user.first_name[0..3], user.first_name[-3..-1]].each do |first|
      users = User.send(:do_filter, first, profile: [:first_name])
      break if users.size > 1
      expect(users.first).to eq user
    end

    users = User.send(:do_filter, 'Hans-Jürgen-Klaus', profile: [:first_name])
    expect(users.size).to eq 0
  end


  it 'filters user with given lastname', :retry => 3 do
    user = Fabricate(:user)
    2.times { Fabricate(:user) }

    [user.last_name, user.last_name.upcase, user.last_name.downcase, user.last_name[0..2], user.last_name[-2..-1]].each do |last|
      users = User.send(:do_filter, last, profile: [:last_name])
      break if users.size > 1
      expect(users.last).to eq user
    end

    users = User.send(:do_filter, 'Schleier-Helwig-Holzhammer', profile: [:last_name])
    expect(users.size).to eq 0
  end


  it 'filters user by last_name and first_name', :retry => 3 do
    user = Fabricate(:user)
    2.times { Fabricate(:user) }

    users = User.send(:do_filter, user.last_name, profile: [:last_name, :first_name])
    break if users.size > 1
    expect(users.last).to eq user

    users = User.send(:do_filter, user.first_name, profile: [:last_name, :first_name])
    break if users.size > 1
    expect(users.last).to eq user
  end


  it 'filters user by last_name and first_name and email', :retry => 3 do
    user = Fabricate(:user)
    2.times { Fabricate(:user) }

    users = User.filter(user.email)
    break if users.size > 1
    expect(users.last).to eq user

    users = User.filter(user.email)
    break if users.size > 1
    expect(users.last).to eq user
  end


  it 'filters user with no params' do
    5.times { Fabricate(:user) }

    users = User.filter(nil)
    expect(users.size).to eq 5
  end

  it 'is restriciting readable_by' do
    user = Fabricate(:user)
    profile = user.profile
    expect(User.readable_by(nil)).to eq []
    expect(User.readable_by(user)).to eq [user]
    profile.update!(readable: 'world')
    expect(User.readable_by(nil)).to eq [user]
    profile.update!(readable: 'community')
    other = Fabricate(:user)
     expect(User.readable_by(other)).to match_array [user, other]
    profile.update!(readable: nil)
    expect(User.readable_by(other)).to match_array [other]
    other.friends << user
    expect(User.readable_by(other)).to match_array [user, other]
    admin = Fabricate(:user)
    admin.add_role('admin')
    expect(User.readable_by(admin)).to match_array [user, other, admin]
  end

  it 'gives no unsubscribed from notification users' do 
    [organization, group, register].each do |resource|
      expect(User.unsubscribed_from_notification('some.key', resource)).to eq []
    end
  end

  it 'gives unsubscribed from notification users' do 
    [organization, group, register].each do |resource|
      NotificationUnsubscriber.create(trackable: resource, user: user, notification_key: 'some.key', channel: 'email')
      expect(User.unsubscribed_from_notification('some.key', resource)).to eq [user]
    end

    [group, register].each do |resource|
      NotificationUnsubscriber.create(trackable: resource, user: resource.managers.first, notification_key: 'other.key', channel: 'email')
    end

    expect(User.unsubscribed_from_notification('other.key', group)).to eq [manager_group, manager_register]
    expect(User.unsubscribed_from_notification('other.key', register)).to eq [manager_register]
    expect(User.unsubscribed_from_notification('other.key', organization)).to eq []
  end

  it 'validates roles and profile' do
    user.add_role(:admin, nil)
    expect(user.valid?).to be true

    user.profile = nil
    expect(user.errors['roles']).not_to be_nil

    user.roles.delete_all
    expect(user.valid?).to be true
  end
end
