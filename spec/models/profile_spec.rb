# coding: utf-8
describe "Profile Model" do

  entity(:user) { Fabricate(:user) }
  entity(:other) { Fabricate(:user) }
  entity(:admin) { Fabricate(:admin) }

  before { 2.times { Fabricate(:user) } }

  xit 'is restricting readable_by', :retry => 3 do
    user = Fabricate(:user)
    profile = user.profile
    expect(Profile.readable_by(nil)).to eq []
    expect(Profile.readable_by(user)).to eq [profile]
    profile.update!(readable: 'world')
    expect(Profile.readable_by(nil)).to eq [profile]
    profile.update!(readable: 'community')
    expect(Profile.readable_by(other)).to match_array [profile, other.profile]
    profile.update!(readable: nil)
    expect(Profile.readable_by(other)).to match_array [other.profile]
    other.friends << user
    expect(Profile.readable_by(other)).to match_array [profile, other.profile]

    expect(Profile.readable_by(admin)).to match_array [profile, other.profile, admin.profile]
  end

  it 'anonymizes email on collections' do
    expect(Profile.anonymized_readable_by(user).collect(&:email)).to include user.email

    Profile.update_all(readable: 'world')
    hidden = ['hidden@buzzn.net'] * (Profile.count - 1)
    expect(Profile.anonymized_readable_by(user).collect(&:email)).to match_array(hidden + [user.email])

    expect(Profile.anonymized_readable_by(admin).collect(&:email)).not_to include 'hidden@buzzn.net'
  end


  it 'anonymizes email on retrieve' do
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
    expect(Profile.anonymized_get(admin.profile.id, admin).email).to eq admin.email
    expect(Profile.anonymized_get(other.profile.id, admin).email).to eq other.email
    expect(Profile.anonymized_get(hidden.profile.id, admin).email).to eq hidden.email
  end

  it 'gets all profiles without attached user as admin' do
    expect(Profile.readable_by(admin).size).to eq Profile.count
    expect(Profile.anonymized_readable_by(admin).size).to eq Profile.count
  end

  it 'clears the user when it gets deleted' do
    admin = Fabricate(:admin)
    admin.profile.destroy
    admin.reload
    expect(admin.roles).to eq []
    expect(admin.profile).to be_nil
  end
end
