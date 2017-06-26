# coding: utf-8
describe "Profile Model" do

  entity(:user) { Fabricate(:user) }
  entity(:other) { Fabricate(:user) }
  entity(:admin) { Fabricate(:admin) }

  before { 2.times { Fabricate(:user) } }


  it 'clears the user when it gets deleted' do
    admin = Fabricate(:admin)
    admin.profile.destroy
    admin.reload
    expect(admin.roles).to eq []
    expect(admin.profile).to be_nil
  end
end
