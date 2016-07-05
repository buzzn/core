describe 'Comments API' do

  it 'creates a root comment with admin token' do
    admin_token     = Fabricate(:admin_access_token)
    group           = Fabricate(:group)
    comment = {
      resource_id: group.id,
      resource_name: 'Group',
      body: FFaker::Lorem.paragraphs.join('-'),
    }

    get_with_token "/api/v1/groups/#{group.id}/comments", admin_token.token
    expect(json['data'].size).to eq(0)
    post_with_token '/api/v1/comments', comment.to_json, admin_token.token
    expect(response).to have_http_status(201)
    expect(json['data']['attributes']['body']).to eq(comment[:body])
    get_with_token "/api/v1/groups/#{group.id}/comments", admin_token.token
    expect(json['data'].size).to eq(1)
  end

  it 'creates a child comment with admin token' do
    admin_token     = Fabricate(:admin_access_token)
    group           = Fabricate(:group_with_two_comments_readable_by_world)
    comments        = group.comment_threads
    child_comment   = comments.find{|c| !c.parent_id.nil?}
    comment = {
      resource_id: group.id,
      resource_name: 'Group',
      body: FFaker::Lorem.paragraphs.join('-'),
      parent_id: child_comment.id,
    }

    get_with_token "/api/v1/groups/#{group.id}/comments", admin_token.token
    expect(json['data'].size).to eq(2)
    post_with_token '/api/v1/comments', comment.to_json, admin_token.token
    expect(response).to have_http_status(201)
    expect(json['data']['attributes']['body']).to eq(comment[:body])
    expect(json['data']['attributes']['parent-id']).to eq(child_comment.id)
    get_with_token "/api/v1/groups/#{group.id}/comments", admin_token.token
    expect(json['data'].size).to eq(3)
  end

  it 'does not create comment with wrong arguments' do
    admin_token     = Fabricate(:admin_access_token)
    group           = Fabricate(:group)
    comment = {
      resource_id: group.id,
      resource_name: 'Group',
      body: FFaker::Lorem.paragraphs.join('-'),
    }

    comment.each do |missing_param, val|
      broken_params = comment.reject { |key, val| key == missing_param }
      post_with_token "/api/v1/comments", broken_params.to_json, admin_token.token
      expect(response).to have_http_status(400)
      expect(json['error']).to start_with("#{missing_param} is missing")
    end

    wrong_resource_id = comment.clone
    wrong_resource_id[:resource_id] = 'xxxxx'
    post_with_token "/api/v1/comments", wrong_resource_id.to_json, admin_token.token
    expect(response).to have_http_status(404)

    wrong_resource_name = comment.clone
    wrong_resource_name[:resource_name] = 'xxxxx'
    post_with_token "/api/v1/comments", wrong_resource_name.to_json, admin_token.token
    expect(response).to have_http_status(400)
    expect(json['error']).to eq('resource_name does not have a valid value')
  end

  it 'creates a comment only with token' do
    access_token  = Fabricate(:access_token)
    group         = Fabricate(:group)
    comment = {
      resource_id: group.id,
      resource_name: 'Group',
      body: FFaker::Lorem.paragraphs.join('-'),
    }

    post_with_token '/api/v1/comments', comment.to_json, access_token.token
    expect(response).to have_http_status(201)
    post_without_token '/api/v1/comments', comment.to_json
    expect(response).to have_http_status(401)
  end

  it 'does not create comment for resource not readable by user' do
    access_token  = Fabricate(:access_token)
    group         = Fabricate(:group_readable_by_friends)
    comment = {
      resource_id: group.id,
      resource_name: 'Group',
      body: FFaker::Lorem.paragraphs.join('-'),
    }

    post_with_token '/api/v1/comments', comment.to_json, access_token.token
    expect(response).to have_http_status(403)
  end

  it 'does not update comment with wrong arguments' do
    admin_token     = Fabricate(:admin_access_token)
    group           = Fabricate(:group_with_two_comments_readable_by_world)
    comments        = group.comment_threads
    child_comment   = comments.find{|c| !c.parent_id.nil?}
    params = { body: FFaker::Lorem.paragraphs.join('-') }

    put_with_token "/api/v1/comments/xxxxx", params.to_json, admin_token.token
    expect(response).to have_http_status(404)
    put_with_token "/api/v1/comments/#{child_comment.id}", {}, admin_token.token
    expect(response).to have_http_status(400)
    expect(json['error']).to eq('body is missing')
  end

  it 'allows only update own comment' do
    wrong_token   = Fabricate(:access_token)
    access_token  = Fabricate(:access_token)
    user          = User.find(access_token.resource_owner_id)
    group         = Fabricate(:group)
    comment_params = {
      commentable_id: group.id,
      commentable_type: 'Group',
      user_id: user.id,
    }
    comment       = Fabricate(:comment, comment_params)
    request_params = { body: 'xxxx' }

    put_with_token "/api/v1/comments/#{comment.id}", request_params.to_json, wrong_token.token
    expect(response).to have_http_status(403)
    put_with_token "/api/v1/comments/#{comment.id}", request_params.to_json, access_token.token
    expect(response).to have_http_status(200)
  end

  it 'does not allow resource manager or admin to update any resource comment' do
    access_token  = Fabricate(:access_token)
    admin_token   = Fabricate(:admin_access_token)
    user          = User.find(access_token.resource_owner_id)
    group         = Fabricate(:group_with_two_comments_readable_by_world)
    comment       = group.comment_threads.first
    user.add_role(:manager, group)

    request_params = { body: 'xxxx' }
    put_with_token "/api/v1/comments/#{comment.id}", request_params.to_json, access_token.token
    expect(response).to have_http_status(403)
    put_with_token "/api/v1/comments/#{comment.id}", request_params.to_json, admin_token.token
    expect(response).to have_http_status(403)
  end

  it 'removes a child comment with admin token' do
    admin_token     = Fabricate(:admin_access_token)
    group           = Fabricate(:group_with_two_comments_readable_by_world)
    comments        = group.comment_threads
    child_comment   = comments.find{|c| !c.parent_id.nil?}

    get_with_token "/api/v1/groups/#{group.id}/comments", admin_token.token
    expect(json['data'].size).to eq(2)
    delete_with_token "/api/v1/comments/#{child_comment.id}", admin_token.token
    expect(response).to have_http_status(200)
    get_with_token "/api/v1/groups/#{group.id}/comments", admin_token.token
    expect(json['data'].size).to eq(1)
  end

  it 'does not remove a root comment even with admin token' do
    admin_token     = Fabricate(:admin_access_token)
    group           = Fabricate(:group_with_two_comments_readable_by_world)
    comments        = group.comment_threads
    root_comment    = comments.find{|c| c.parent_id.nil?}

    delete_with_token "/api/v1/comments/#{root_comment.id}", admin_token.token
    expect(response).to have_http_status(403)
  end

  it 'allows only remove own comment' do
    wrong_token   = Fabricate(:access_token)
    access_token  = Fabricate(:access_token)
    user          = User.find(access_token.resource_owner_id)
    group         = Fabricate(:group)
    comment_params = {
      commentable_id: group.id,
      commentable_type: 'Group',
      user_id: user.id,
    }
    comment       = Fabricate(:comment, comment_params)

    delete_with_token "/api/v1/comments/#{comment.id}", wrong_token.token
    expect(response).to have_http_status(403)
    delete_with_token "/api/v1/comments/#{comment.id}", access_token.token
    expect(response).to have_http_status(200)
  end

  it 'allows resource manager to delete resource comment-child' do
    access_token  = Fabricate(:access_token)
    user          = User.find(access_token.resource_owner_id)
    group         = Fabricate(:group_with_two_comments_readable_by_world)
    comments      = group.comment_threads
    root_comment  = comments.find{|c| c.parent_id.nil?}
    child_comment = comments.find{|c| !c.parent_id.nil?}
    user.add_role(:manager, group)

    delete_with_token "/api/v1/comments/#{root_comment.id}", access_token.token
    expect(response).to have_http_status(403)
    delete_with_token "/api/v1/comments/#{child_comment.id}", access_token.token
    expect(response).to have_http_status(200)
  end


end