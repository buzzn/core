# coding: utf-8
describe "User Model" do

  entity(:organization) { Fabricate(:organization, mode: :electricity_supplier) }
  entity(:tribe) do
    group = Fabricate(:tribe)
    manager_group.add_role(:manager, group)
    group
  end

  entity(:register) do
    register = Fabricate(:output_register, meter: Fabricate(:meter))
    manager_register.add_role(:manager, register)
    register.update! group: tribe
    register
  end

  entity(:user) { Fabricate(:user) }
  entity!(:admin) { Fabricate(:admin) }
  entity(:manager_register) { Fabricate(:user) }
  entity(:manager_group) { Fabricate(:user) }

  before { 2.times { Fabricate(:user) } }

  it 'filters user with given email', :retry => 3 do
    [user.email, user.email.upcase, user.email.downcase, user.email[0..3], user.email[-3..-1]].each do |first|
      users = User.send(:do_filter, first, :email)
      break if users.size > 1
      expect(users.first).to eq user
    end

    users = User.send(:do_filter, 'haJürK@example.xom', :email)
    expect(users.size).to eq 0
  end

  it 'filters user with given firstname' do
    [user.first_name, user.first_name.upcase, user.first_name.downcase, user.first_name[0..3], user.first_name[-3..-1]].each do |first|
      users = User.send(:do_filter, first, profile: [:first_name])
      expect(users).to include user
    end

    users = User.send(:do_filter, 'Hans-Jürgen-Klaus', profile: [:first_name])
    expect(users.size).to eq 0
  end


  it 'filters user with given lastname', :retry => 3 do
    [user.last_name, user.last_name.upcase, user.last_name.downcase, user.last_name[0..2], user.last_name[-2..-1]].each do |last|
      users = User.send(:do_filter, last, profile: [:last_name])
      expect(users).to include user
    end

    users = User.send(:do_filter, 'Schleier-Helwig-Holzhammer', profile: [:last_name])
    expect(users.size).to eq 0
  end

  it 'filters user by last_name and first_name' do
    users = User.send(:do_filter, user.last_name, profile: [:last_name, :first_name])
    expect(users).to include user

    users = User.send(:do_filter, user.first_name, profile: [:last_name, :first_name])
    expect(users).to include user
  end

  it 'filters user with no params' do
    users = User.filter(nil)
    expect(users.size).to eq User.count 
  end

  it 'is restriciting readable_by' do
    profile = user.profile
    expect(User.readable_by(nil)).to eq []
    expect(User.readable_by(user)).to include user
    profile.update!(readable: 'world')
    expect(User.readable_by(nil)).to eq [user]
    profile.update!(readable: 'community')
    other = Fabricate(:user)
     expect(User.readable_by(other)).to match_array [user, other]
    profile.update!(readable: nil)
    expect(User.readable_by(other)).to match_array [other]
    other.friends << user
    expect(User.readable_by(other)).to match_array [user, other]
    expect(User.readable_by(admin)).to match_array User.all
  end

  it 'gives no unsubscribed from notification users' do
    [organization, tribe, register].each do |resource|
      expect(User.unsubscribed_from_notification('any.key', resource)).to eq []
    end
  end

  it 'gives unsubscribed from notification users' do
    [organization, tribe, register].each do |resource|
      NotificationUnsubscriber.create(trackable: resource, user: user, notification_key: 'some.key', channel: 'email')
      expect(User.unsubscribed_from_notification('some.key', resource)).to eq [user]
    end

    [tribe, register].each do |resource|
      NotificationUnsubscriber.create(trackable: resource, user: resource.managers.first, notification_key: 'other.key', channel: 'email')
    end

    expect(User.unsubscribed_from_notification('other.key', tribe)).to eq [manager_group]
    expect(User.unsubscribed_from_notification('other.key', register)).to eq [manager_register]
    expect(User.unsubscribed_from_notification('other.key', organization)).to eq []
  end

  it 'validates roles and profile' do
    user = Fabricate(:admin)
    expect(user.valid?).to be true

    user.profile = nil
    expect(user.errors['roles']).not_to be_nil

    user.roles.delete_all
    expect(user.valid?).to be true
  end
end
