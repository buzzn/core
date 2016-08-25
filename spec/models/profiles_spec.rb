# coding: utf-8
describe "Profile Model" do

  it 'is restricting readable_by' do
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

end
