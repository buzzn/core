describe 'Roles API' do

  it 'adds a member role to metering point for some user' do
    post_without_token '/api/v1/roles/add', {}
    puts(response.to_a)
    expect(response).to have_http_status(200)
  end

end