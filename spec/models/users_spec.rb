# coding: utf-8
describe "User Model" do

  it 'filters user with given email' do
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

  it 'filters user with given firstname' do
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


  it 'filters user with given lastname' do
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


  it 'filters user by last_name and first_name' do
    user = Fabricate(:user)
    2.times { Fabricate(:user) }

    users = User.send(:do_filter, user.last_name, profile: [:last_name, :first_name])
    break if users.size > 1
    expect(users.last).to eq user

    users = User.send(:do_filter, user.first_name, profile: [:last_name, :first_name])
    break if users.size > 1
    expect(users.last).to eq user
  end


  it 'filters user by last_name and first_name and email' do
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
end
