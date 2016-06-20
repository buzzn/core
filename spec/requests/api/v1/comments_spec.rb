describe 'Comments API' do

  it 'does get usernames by user ids for profiles to which user have access' do
    public_user = Fabricate(:user)
    public_user.profile.readable = 'world'
    public_user.profile.first_name = 'Fraa'
    public_user.profile.last_name = 'Erasmas'
    public_user.profile.save
    private_user = Fabricate(:user)
    private_user.profile.readable = 'friends'
    private_user.profile.save

    params = { ids: [public_user.id, private_user.id] }
    get_without_token '/api/v1/comments/usernames', params
    expect(response).to have_http_status(200)
    expect(json[public_user.id]).to eq('Fraa Erasmas')
    expect(json[private_user.id]).to eq('Hidden')
  end


end
