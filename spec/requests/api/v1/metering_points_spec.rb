describe "Metering Points API" do


  it 'does not gets a metering_point without token' do
    metering_point = Fabricate(:metering_point)
    get_without_token "/api/v1/metering-points/#{metering_point.id}"
    expect(response).not_to be_successful
  end

  it 'does gets a metering_point with admin token' do
    access_token  = Fabricate(:admin_access_token)
    metering_point = Fabricate(:metering_point)
    get_with_token "/api/v1/metering-points/#{metering_point.id}", access_token.token
    expect(response).to be_successful
  end

  it 'does gets a metering_point as friend' do
    access_token = Fabricate(:access_token_with_friend_and_metering_point)

    metering_point1 = MeteringPoint.first
    metering_point2 = MeteringPoint.last

    get_with_token "/api/v1/metering-points/#{metering_point2.id}", access_token.token
    expect(response).to be_successful

    get_with_token "/api/v1/metering-points/#{metering_point1.id}", access_token.token
    expect(response).to be_successful

    metering_point3 = Fabricate(:metering_point) # metering_point from unknown user
    get_with_token "/api/v1/metering-points/#{metering_point3.id}", access_token.token
    expect(response).not_to be_successful
  end


end
