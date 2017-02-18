describe "Profiles API" do

  let(:page_overload) { 33 }


  it 'does not get all profiles with regular token or without token' do
    Fabricate(:profile)
    Fabricate(:profile)
    access_token = Fabricate(:simple_access_token)
    get_with_token '/api/v1/profiles', {}, access_token.token
    expect(response).to have_http_status(403)
    get_without_token '/api/v1/profiles'
    expect(response).to have_http_status(401)
  end

  it 'get all profiles with full access token' do
    5.times.each { Fabricate(:profile) }
    access_token = Fabricate(:full_access_token_as_admin)
    get_with_token '/api/v1/profiles', {}, access_token.token
    expect(response).to have_http_status(200)
    expect(json['data'].size).to eq(Profile.all.count)
    json['data'].each do |data|
      expect(data['attributes']['email']).not_to eq 'hidden@buzzn.net'
    end

    access_token = Fabricate(:full_access_token)
    token_profile = Profile.where(user_id: access_token.resource_owner_id).first
    get_with_token '/api/v1/profiles', {}, access_token.token
    expect(response).to have_http_status(200)
    expect(json['data'].size).to eq(1)
    expect(json['data'].first['id']).to eq token_profile.id
    expect(json['data'].first['attributes']['email']).to eq User.find(access_token.resource_owner_id).email

    Profile.all.each {|p| p.update! readable: 'world' }
    get_with_token '/api/v1/profiles', {}, access_token.token
    expect(response).to have_http_status(200)
    json['data'].each do |data|
      if data['id'] != token_profile.id
        expect(data['attributes']['email']).to eq 'hidden@buzzn.net'
      else
        expect(data['attributes']['email']).to eq User.find(access_token.resource_owner_id).email
      end
    end

  end


  it 'paginate profiles with full access token' do
    page_overload.times do
      Fabricate(:profile)
    end
    access_token = Fabricate(:full_access_token_as_admin)

    get_with_token "/api/v1/profiles", {per_page: 200}, access_token.token
    expect(response).to have_http_status(422)

    pages_profile_ids = []

    1.upto(4) do |i|
      get_with_token '/api/v1/profiles', {page: i, order_direction: 'DESC', order_by: 'created_at'}, access_token.token
      expect(response).to have_http_status(200)
      expect(json['meta']['total_pages']).to eq(4)
      json['data'].each do |data|
        pages_profile_ids << data['id']
      end
    end
    expect(pages_profile_ids.uniq.length).to eq(pages_profile_ids.length)
  end


  xit 'gets even friend-readable profile without token' do
    profile = Fabricate(:friends_readable_profile)
    get_without_token "/api/v1/profiles/#{profile.id}"
    expect(response).to have_http_status(200)
  end


  it 'does not creates a profile as simple user' do
    access_token = Fabricate(:simple_access_token)
    profile = Fabricate.build(:profile)

    request_params = {
      user_name:  profile.user_name,
      first_name: profile.first_name,
      last_name:  profile.last_name
    }.to_json

    post_with_token "/api/v1/profiles", request_params, access_token.token
    expect(response).to have_http_status(403)
  end

  it 'does not create a profile with missing parameters' do
    access_token = Fabricate(:full_access_token_as_admin)
    profile = Fabricate.build(:profile)

    request_params = {
      user_name:  profile.user_name,
      first_name: profile.first_name,
      last_name:  profile.last_name
    }

    request_params.keys.each do |name|
      params = request_params.reject { |k,v| k == name }
      post_with_token "/api/v1/profiles", params.to_json, access_token.token

      expect(response).to have_http_status(422)
      json['errors'].each do |error|
        expect(error['source']['pointer']).to eq "/data/attributes/#{name}"
        expect(error['title']).to eq 'Invalid Attribute'
        expect(error['detail']).to eq "#{name} is missing"
      end
    end
  end


  it 'does not create a profile with invalid parameters' do
    access_token = Fabricate(:full_access_token_as_admin)
    profile = Fabricate.build(:profile)

    request_params = {
      user_name:  profile.user_name,
      first_name: profile.first_name,
      last_name:  profile.last_name
    }

    request_params.keys.each do |name|
      params = request_params.dup
      params[name] = 'a' * 2000

      post_with_token "/api/v1/profiles", params.to_json, access_token.token

      expect(response).to have_http_status(422)
      json['errors'].each do |error|
        expect(error['source']['pointer']).to eq "/data/attributes/#{name}"
        expect(error['title']).to eq 'Invalid Attribute'
        expect(error['detail']).to match /#{name}/
      end
    end
  end

  it 'creates a profile as admin' do
    access_token = Fabricate(:full_access_token_as_admin)
    profile = Fabricate.build(:profile)

    request_params = {
      user_name:  profile.user_name,
      first_name: profile.first_name,
      last_name:  profile.last_name
    }.to_json

    post_with_token "/api/v1/profiles", request_params, access_token.token

    expect(response).to have_http_status(201)
    expect(json['data']['attributes']['first-name']).to eq(profile.first_name)
    expect(json['data']['attributes']['last-name']).to eq(profile.last_name)
  end


  it 'updates profile as admin' do
    access_token  = Fabricate(:full_access_token_as_admin)
    profile       = Fabricate(:profile)

    params = { first_name: 'fName', last_name: 'lName', user_name: 'uName' }

    patch_with_token "/api/v1/profiles/#{profile.id}", params.to_json, access_token.token
    expect(response).to have_http_status(200)
    params.each do |key, val|
      expect(json['data']['attributes'][key.to_s.dasherize]).to eq(val)
    end
  end


  it 'does not update a profile with invalid parameters' do
    access_token = Fabricate(:full_access_token_as_admin)
    profile = Fabricate(:profile)

    request_params = {
      user_name:  profile.user_name,
      first_name: profile.first_name,
      last_name:  profile.last_name
    }

    request_params.keys.each do |name|
      params = request_params.dup
      params[name] = 'a' * 200

      patch_with_token "/api/v1/profiles/#{profile.id}", params.to_json, access_token.token

      expect(response).to have_http_status(422)
      json['errors'].each do |error|
        expect(error['source']['pointer']).to eq "/data/attributes/#{name}"
        expect(error['title']).to eq 'Invalid Attribute'
        expect(error['detail']).to match /#{name}/
      end
    end
  end


  it 'get profile groups readable by world with or without token' do
    access_token      = Fabricate(:simple_access_token).token
    user              = Fabricate(:user)
    profile           = user.profile
    profile.readable  = 'world'
    profile.save
    group             = Fabricate(:tribe)
    register    = Fabricate(:input_meter).input_register
    register.update(readable: :world)
    user.add_role(:member, register)
    group.registers << register

    get_with_token "/api/v1/profiles/#{profile.id}/groups", access_token
    expect(response).to have_http_status(200)
    expect(json['data'].first['id']).to eq(group.id)
    get_without_token "/api/v1/profiles/#{profile.id}/groups"
    expect(response).to have_http_status(200)
    expect(json['data'].first['id']).to eq(group.id)
  end

  it 'get community-readable groups for world-readable profile only with token' do
    access_token      = Fabricate(:simple_access_token)
    user              = Fabricate(:user)
    profile           = user.profile
    profile.readable  = 'world'
    profile.save
    group             = Fabricate(:tribe_readable_by_community)
    register    = Fabricate(:output_meter).output_register
    register.update(readable: :community)
    user.add_role(:member, register)
    group.registers << register

    get_without_token "/api/v1/profiles/#{profile.id}/groups"
    expect(response).to have_http_status(200)
    expect(json['data']).to eq([])
    get_with_token "/api/v1/profiles/#{profile.id}/groups", access_token.token
    expect(response).to have_http_status(200)
    expect(json['data'].first['id']).to eq(group.id)
  end

  it 'get friends-readable groups for world-readable profile only with friend token' do
    access_token      = Fabricate(:access_token_with_friend)
    wrong_token       = Fabricate(:simple_access_token).token
    token_user        = User.find(access_token.resource_owner_id)
    token_user_friend = token_user.friends.first
    profile           = token_user_friend.profile
    profile.readable  = 'world'
    profile.save
    group             = Fabricate(:tribe_readable_by_friends)
    register    = Fabricate(:input_meter).input_register
    register.update(readable: :friends)
    token_user_friend.add_role(:member, register)
    group.registers << register

    get_with_token "/api/v1/profiles/#{profile.id}/groups", wrong_token
    expect(response).to have_http_status(200)
    expect(json['data']).to eq([])
    get_with_token "/api/v1/profiles/#{profile.id}/groups", access_token.token
    expect(response).to have_http_status(200)
    expect(json['data'].first['id']).to eq(group.id)

    token_user_friend.remove_role(:member, register)
    token_user_friend.add_role(:manager, register)

    get_with_token "/api/v1/profiles/#{profile.id}/groups", access_token.token
    expect(response).to have_http_status(200)
    expect(json['data'].first['id']).to eq(group.id)
  end

  it 'does not get members-readable groups for world-readable profile even with friend token' do
    access_token      = Fabricate(:access_token_with_friend)
    token_user        = User.find(access_token.resource_owner_id)
    token_user_friend = token_user.friends.first
    profile           = token_user_friend.profile
    profile.readable  = 'world'
    profile.save
    group             = Fabricate(:tribe_readable_by_members)
    register    = Fabricate(:output_meter).output_register
    register.update(readable: :friends)
    token_user_friend.add_role(:member, register)
    group.registers << register

    get_with_token "/api/v1/profiles/#{profile.id}/groups", access_token.token
    expect(response).to have_http_status(200)
    expect(json['data']).to eq([])
  end

  it 'does not get friends-readable groups for world-readable profile with or without token' do
    access_token      = Fabricate(:simple_access_token)
    wrong_token       = Fabricate(:simple_access_token).token
    token_user        = User.find(access_token.resource_owner_id)
    profile           = token_user.profile
    profile.readable  = 'world'
    profile.save
    group             = Fabricate(:tribe_readable_by_friends)
    register    = Fabricate(:input_meter).input_register
    register.update(readable: :world)
    token_user.add_role(:member, register)
    group.registers << register

    get_without_token "/api/v1/profiles/#{profile.id}/groups"
    expect(response).to have_http_status(200)
    expect(json['data']).to eq([])
    get_with_token "/api/v1/profiles/#{profile.id}/groups", wrong_token
    expect(response).to have_http_status(200)
    expect(json['data']).to eq([])
  end

  it 'paginate groups', retry: 3 do
    user              = Fabricate(:user)
    profile           = user.profile
    profile.readable  = 'world'
    profile.save
    page_overload.times do
      group       = Fabricate(:tribe)
      register    = Fabricate(:output_meter).output_register
      register.update(readable: :world)
      user.add_role(:member, register)
      group.registers << register
    end

    get_without_token "/api/v1/profiles/#{profile.id}/groups"
    expect(response).to have_http_status(200)
    expect(json['meta']['total_pages']).to eq(4)

    get_without_token "/api/v1/profiles/#{profile.id}/groups", {per_page: 200}
    expect(response).to have_http_status(422)
  end

  it 'get friends for world-readable profile with or without token' do
    user              = Fabricate(:user_with_friend)
    profile           = user.profile
    profile.readable  = 'world'
    profile.save
    friend            = user.friends.first
    friend.profile.readable = 'world'
    friend.profile.save
    access_token      = Fabricate(:simple_access_token).token

    get_with_token "/api/v1/profiles/#{profile.id}/friends", access_token
    expect(response).to have_http_status(200)
    expect(json['data'].first['id']).to eq(friend.id)
    get_without_token "/api/v1/profiles/#{profile.id}/friends"
    expect(response).to have_http_status(200)
    expect(json['data'].first['id']).to eq(friend.id)
  end

  it 'get friends for community-readable profile only with token' do
    user              = Fabricate(:user_with_friend)
    profile           = user.profile
    profile.readable  = 'community'
    profile.save
    friend            = user.friends.first
    friend.profile.readable = 'world'
    friend.profile.save
    access_token      = Fabricate(:simple_access_token).token

    get_with_token "/api/v1/profiles/#{profile.id}/friends", access_token
    expect(response).to have_http_status(200)
    expect(json['data'].first['id']).to eq(friend.id)
    get_without_token "/api/v1/profiles/#{profile.id}/friends"
    expect(response).to have_http_status(403)
  end

  it 'paginate friends' do
    user              = Fabricate(:user)
    profile           = user.profile
    profile.readable  = 'world'
    profile.save
    page_overload.times do
      friend                  = Fabricate(:user)
      friend_profile          = friend.profile
      friend_profile.readable = 'world'
      friend_profile.save
      user.friends << friend
    end
    get_without_token "/api/v1/profiles/#{profile.id}/friends"
    expect(response).to have_http_status(200)
    expect(json['meta']['total_pages']).to eq(4)

    get_without_token "/api/v1/profiles/#{profile.id}/friends", {per_page: 200}
    expect(response).to have_http_status(422)
  end

  it 'get profile registers readable by world with or without token' do
    access_token      = Fabricate(:simple_access_token).token
    user              = Fabricate(:user)
    profile           = user.profile
    profile.readable  = 'world'
    profile.save
    register    = Fabricate(:input_meter).input_register
    register.update(readable: :world)
    user.add_role(:member, register)

    get_with_token "/api/v1/profiles/#{profile.id}/registers", access_token
    expect(response).to have_http_status(200)
    expect(json['data'].first['id']).to eq(register.id)
    get_without_token "/api/v1/profiles/#{profile.id}/registers"
    expect(response).to have_http_status(200)
    expect(json['data'].first['id']).to eq(register.id)
  end

  it 'get community-readable registers for world-readable profile only with token' do
    access_token      = Fabricate(:simple_access_token)
    user              = Fabricate(:user)
    profile           = user.profile
    profile.readable  = 'world'
    profile.save
    register    = Fabricate(:output_meter).output_register
    register.update(readable: :community)
    user.add_role(:member, register)

    get_without_token "/api/v1/profiles/#{profile.id}/registers"
    expect(response).to have_http_status(200)
    expect(json['data']).to eq([])
    get_with_token "/api/v1/profiles/#{profile.id}/registers", access_token.token
    expect(response).to have_http_status(200)
    expect(json['data'].first['id']).to eq(register.id)
  end

  it 'get friends-readable registers for world-readable profile only with friend token' do
    access_token      = Fabricate(:access_token_with_friend)
    wrong_token       = Fabricate(:simple_access_token).token
    token_user        = User.find(access_token.resource_owner_id)
    token_user_friend = token_user.friends.first
    profile           = token_user_friend.profile
    profile.readable  = 'world'
    profile.save
    register    = Fabricate(:input_meter).input_register
    register.update(readable: :friends)
    token_user_friend.add_role(:member, register)

    get_with_token "/api/v1/profiles/#{profile.id}/registers", access_token.token
    expect(response).to have_http_status(200)
    expect(json['data'].first['id']).to eq(register.id)
    get_with_token "/api/v1/profiles/#{profile.id}/registers", wrong_token
    expect(response).to have_http_status(200)
    expect(json['data']).to eq([])
  end

  it 'does not get members-readable registers for world-readable profile even with friend token' do
    access_token      = Fabricate(:access_token_with_friend)
    token_user        = User.find(access_token.resource_owner_id)
    token_user_friend = token_user.friends.first
    profile           = token_user_friend.profile
    profile.readable  = 'world'
    profile.save
    register    = Fabricate(:output_meter).output_register
    register.update(readable: :members)
    token_user_friend.add_role(:member, register)

    get_with_token "/api/v1/profiles/#{profile.id}/registers", access_token.token
    expect(response).to have_http_status(200)
    expect(json['data']).to eq([])
  end

  it 'does not get friends-readable registers for world-readable profile with or without token' do
    access_token      = Fabricate(:simple_access_token)
    wrong_token       = Fabricate(:simple_access_token).token
    token_user        = User.find(access_token.resource_owner_id)
    profile           = token_user.profile
    profile.readable  = 'world'
    profile.save
    register    = Fabricate(:input_meter).input_register
    register.update(readable: :friends)
    token_user.add_role(:member, register)

    get_without_token "/api/v1/profiles/#{profile.id}/registers"
    expect(response).to have_http_status(200)
    expect(json['data']).to eq([])
    get_with_token "/api/v1/profiles/#{profile.id}/registers", wrong_token
    expect(response).to have_http_status(200)
    expect(json['data']).to eq([])
  end

  it 'paginate registers' do
    user              = Fabricate(:user)
    profile           = user.profile
    profile.readable  = 'world'
    profile.save
    page_overload.times do
      register  = Fabricate([:input_meter, :output_meter].sample).registers.first
      register.update(readable: :world)
      user.add_role(:member, register)
    end
    get_without_token "/api/v1/profiles/#{profile.id}/registers"
    expect(response).to have_http_status(200)
    expect(json['meta']['total_pages']).to eq(4)

    get_without_token "/api/v1/profiles/#{profile.id}/registers", {per_page: 200}
    expect(response).to have_http_status(422)
  end



end
