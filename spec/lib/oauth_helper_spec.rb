# coding: utf-8
describe "OAuth Helper" do

  let(:user) { Fabricate(:user) }
  let(:rails_view) { Fabricate(:application, name: 'Buzzn RailsView') }

  subject { OAuthHelper.new(user) }

  before { rails_view }

  it 'finds the RailsView app' do
    expect(subject.rails_view).not_to be_nil
  end

  it 'returns without username/passord the access-token without expiration if this is the only access-code' do
    expect(subject.token(nil, nil).expires_in).to be_nil
    expect(user.access_tokens.size).to eq 1
  end

  it 'returns access-token with expiration with username/password' do
    expected = Fabricate(:full_access_token, application_id: rails_view.id, resource_owner_id: user.id, expires_in: 7200, refresh_token: '1234567890')
    access_token = subject.token(user.email, user.password)
    expect(access_token.expires_in).not_to be_nil
    expect(access_token.token).to eq expected.token
  end
end
