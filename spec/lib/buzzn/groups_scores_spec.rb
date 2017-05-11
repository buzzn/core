

#
# deprecated and needs to ported to the new systematic for endpoint tests
#




describe "groups" do

  let(:page_overload) { 33 }


  [nil, :sufficiency, :closeness, :autarchy, :fitting].each do |mode|

    it "fails the related scores without interval using mode #{mode}" do
      group                 = Fabricate(:tribe)
      now                   = Time.current - 2.days
      params = { mode: mode, timestamp: now }
      get_without_token "/api/v1/groups/#{group.id}/scores", params
      expect(response).to have_http_status(422)
      expect(json['errors'].first['parameter']).to eq 'interval'
    end

    [:day, :month, :year].each do |interval|
      it "fails the related #{interval}ly scores without timestamp using mode #{mode}" do
        group                 = Fabricate(:tribe)
        params = { mode: mode, interval: interval }
        get_without_token "/api/v1/groups/#{group.id}/scores", params
        expect(response).to have_http_status(422)
        expect(json['errors'].first['parameter']).to eq 'timestamp'
      end

      it "gets the related #{interval}ly scores with mode '#{mode}'" do
        group                 = Fabricate(:tribe)
        now                   = Time.current - 2.days
        interval_information  = Group::Base.score_interval(interval.to_s, now.to_i)
        5.times do
          Score.create(mode: mode || 'autarchy', interval: interval_information[0], interval_beginning: interval_information[1], interval_end: interval_information[2], value: (rand * 10).to_i, scoreable_type: 'Group::Base', scoreable_id: group.id)
        end
        interval_information  = Group::Base.score_interval(interval.to_s, 123123)
        Score.create(mode: mode || 'autarchy', interval: interval_information[0], interval_beginning: interval_information[1], interval_end: interval_information[2], value: (rand * 10).to_i, scoreable_type: 'Group::Base', scoreable_id: group.id)

        params = { mode: mode, interval: interval, timestamp: now }
        get_without_token "/api/v1/groups/#{group.id}/scores", params
        expect(response).to have_http_status(200)
        expect(json.size).to eq(5)
        sample = json.first
        expect(sample['mode']).to eq((mode || 'autarchy').to_s)
        expect(sample['interval']).to eq(interval.to_s)
        expect(sample['interval_beginning'] < now.as_json && now.as_json < sample['interval_end']).to eq true
      end
    end
  end


  it 'get all scores' do
    group                 = Fabricate(:tribe)
    now                   = Time.current - 2.days
    interval_information  = group.set_score_interval('day', now.to_i)
    page_overload.times do
      Score.create(mode: 'autarchy', interval: interval_information[0], interval_beginning: interval_information[1], interval_end: interval_information[2], value: (rand * 10).to_i, scoreable_type: 'Group::Base', scoreable_id: group.id)
    end
    params = { interval: 'day', timestamp: now }
    get_without_token "/api/v1/groups/#{group.id}/scores", params
    expect(response).to have_http_status(200)
    expect(json.size).to eq(page_overload)
  end

  it 'gets scores for the current day' do
    group                 = Fabricate(:tribe)
    now                   = Time.current
    yesterday             = Time.current - 1.day
    interval_information  = group.set_score_interval('day', yesterday.to_i)
    page_overload.times do
      Score.create(mode: 'autarchy', interval: interval_information[0], interval_beginning: interval_information[1], interval_end: interval_information[2], value: (rand * 10).to_i, scoreable_type: 'Group::Base', scoreable_id: group.id)
    end
    params = { interval: 'day', timestamp: now }
    get_without_token "/api/v1/groups/#{group.id}/scores", params
    expect(response).to have_http_status(200)
    expect(json.size).to eq(page_overload)
  end

  it 'get all managers' do
    access_token  = Fabricate(:simple_access_token)
    group         = Fabricate(:tribe)
    page_overload.times do
      user = Fabricate(:user)
      user.profile.update(readable: 'world')
      user.add_role(:manager, group)
    end
    page_overload.times do
      user = Fabricate(:user)
      user.add_role(:manager, group)
    end
    get_with_token "/api/v1/groups/#{group.id}/managers", access_token.token
    expect(response).to have_http_status(200)
    expect(json.size).to eq(page_overload)

    access_token  = Fabricate(:full_access_token_as_admin)
    get_with_token "/api/v1/groups/#{group.id}/managers", access_token.token
    expect(response).to have_http_status(200)
    expect(json.size).to eq(page_overload * 2)
  end

  it 'get all members' do
    access_token  = Fabricate(:simple_access_token)
    group         = Fabricate(:tribe_with_members_readable_by_world, members: page_overload * 2)

    group.members[0..page_overload].each do |u|
      u.profile.update(readable: 'world')
    end

    get_with_token "/api/v1/groups/#{group.id}/members", access_token.token
    expect(response).to have_http_status(200)
    expect(json.size).to eq(page_overload + 1)

    access_token  = Fabricate(:full_access_token_as_admin)
    get_with_token "/api/v1/groups/#{group.id}/members", access_token.token
    expect(response).to have_http_status(200)
    expect(json.size).to eq(page_overload * 2)
  end


  it 'gets the related energy-producers/energy-consumers for group' do
    access_token  = Fabricate(:simple_access_token)
    group         = Fabricate(:tribe)
    user          = Fabricate(:user)
    consumer      = Fabricate(:user)
    producer      = Fabricate(:user)
    register_in         = Fabricate(:input_meter).input_register
    register_out        = Fabricate(:output_meter).output_register
    user.add_role(:member, register_in)
    user.add_role(:manager, register_in)
    user.add_role(:member, register_out)
    user.add_role(:manager, register_out)
    producer.add_role(:manager, register_in)
    consumer.add_role(:member, register_in)
    producer.add_role(:member, register_out)
    consumer.add_role(:manager, register_out)
    group.registers += [register_in, register_out]

    get_with_token "/api/v1/groups/#{group.id}/energy-consumers", access_token.token
    expect(response).to have_http_status(200)
    expect(json.size).to eq(0)

    manager = User.find(access_token.resource_owner_id)
    manager.add_role(:manager, register_in)
    manager.add_role(:member, register_out)

    get_with_token "/api/v1/groups/#{group.id}/energy-consumers", access_token.token
    expect(response).to have_http_status(200)
    expect(json.size).to eq(1)
  end


end
