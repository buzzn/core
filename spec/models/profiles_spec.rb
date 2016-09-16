# coding: utf-8
describe "Profile Model" do

  it 'is restricting readable_by', :retry => 3 do
    user = Fabricate(:user)
    profile = user.profile
    expect(Profile.readable_by(nil)).to eq []
    expect(Profile.readable_by(user)).to eq [profile]
    profile.update!(readable: 'world')
    expect(Profile.readable_by(nil)).to eq [profile]
    profile.update!(readable: 'community')
    other = Fabricate(:user)
    expect(Profile.readable_by(other)).to match_array [profile, other.profile]
    profile.update!(readable: nil)
    expect(Profile.readable_by(other)).to match_array [other.profile]
    other.friends << user
    expect(Profile.readable_by(other)).to match_array [profile, other.profile]
    admin = Fabricate(:user)
    admin.add_role('admin')
    expect(Profile.readable_by(admin)).to match_array [profile, other.profile, admin.profile]
  end

  it 'anonymizes email on collections', :retry => 3 do
    user = Fabricate(:user)
    Fabricate(:user)
    Fabricate(:user)
    Fabricate(:user)

    expect(Profile.anonymized_readable_by(user).collect(&:email)).to eq [user.email]

    User.all.each {|u| u.profile.update! readable: 'world'}
    hidden = ['hidden@buzzn.net'] * (Profile.count - 1)
    expect(Profile.anonymized_readable_by(user).collect(&:email)).to match_array(hidden + [user.email])

    user.add_role(:admin, nil)
    hidden << 'hidden@buzzn.net'
    expect(Profile.anonymized_readable_by(user).collect(&:email).include?('hidden@buzzn.net')).to eq false
  end


  it 'anonymizes email on get', :retry => 3 do
    user   = Fabricate(:user)
    other  = Fabricate(:user)
    other.profile.update! readable: 'world'
    hidden =  Fabricate(:user)
    hidden.profile.update! readable: 'members'

    # user can see his/her email
    expect(Profile.anonymized_get(user.profile.id, user).email).to eq user.email

    # anonymized email when not user's profile
    expect(Profile.anonymized_get(other.profile.id, user).email).to eq 'hidden@buzzn.net'
    # has some warning - not sure how to avoid
    expect(Profile.anonymized_get(other.profile.id, nil).email).to eq 'hidden@buzzn.net'

    # not readable by user
    expect(Profile.anonymized_get(hidden.profile.id, user)).to be_nil

    # unknown id
    expect{Profile.anonymized_get('some-unknown-id', user)}.to raise_error ActiveRecord::RecordNotFound

    # admin can see all
    user.add_role(:admin, nil)
    expect(Profile.anonymized_get(user.profile.id, user).email).to eq user.email
    expect(Profile.anonymized_get(other.profile.id, user).email).to eq other.email
    expect(Profile.anonymized_get(hidden.profile.id, user).email).to eq hidden.email
  end

  it 'gets all profiles without attached user as admin', :retry => 3 do
    user = Fabricate(:user)
    user.add_role(:admin, nil)
    Fabricate(:profile)
    Fabricate(:profile)
    Fabricate(:profile)
    expect(Profile.readable_by(user).size).to eq Profile.count
    expect(Profile.anonymized_readable_by(user).size).to eq Profile.count
  end
end
