describe "groups" do


  let(:admin) do
    Fabricate(:admin_token)
  end

  let(:user) do
    Fabricate(:user_token)
  end

  let(:other) do
    Fabricate(:user_token)
  end

  let(:anonymous_denied_json) do
    {
      "errors" => [
        { "title"=>"Permission Denied",
          "detail"=>"retrieve Group::Base: permission denied for User: --anonymous--" }
      ]
    }
  end

  let(:denied_json) do
    json = anonymous_denied_json.dup
    json['errors'][0]['detail'].sub! /--anonymous--/, user.resource_owner_id 
    json
  end

  let(:anonymous_not_found_json) do
    {
      "errors" => [
        { "title"=>"Record Not Found",
          "detail"=>"Group::Base: bla-blub not found" }
      ]
    }
  end

  let(:not_found_json) do
    json = anonymous_not_found_json.dup
    json['errors'][0]['detail'] = "Group::Base: bla-blub not found by User: #{admin.resource_owner_id}"
    json
  end

  let(:tribe) { Fabricate(:tribe) }

  let(:localpool) { Fabricate(:localpool) }

  let(:group) do
    group = Fabricate(:localpool)
    User.find(user.resource_owner_id).add_role(:manager, group)
    group
  end

  context 'GET' do

    let(:group_json) do
      {
        "data"=>{
          "id"=>group.id,
          "type"=>"group-localpools",
          "attributes"=>{
            "type"=>"group_localpool",
            "name"=>group.name,
            "description"=>group.description,
            "readable"=>group.readable,
            "updatable"=>true,
            "deletable"=>true,},
          "relationships"=>{
            "registers"=>{
              "data"=>[]
            },
            "meters"=>{
              "data"=> group.meters.collect do |meter|
                {
                  "id"=>meter.id,
                  'type'=>'meter-virtuals'
                }
              end
            },
            "managers"=>{
              "data"=>group.managers.collect do |manager|
                {
                  "id"=>manager.id,
                  "type"=>"users"
                }
              end
            },
            "energy-producers"=>{
              "data"=>[]
            },
            "energy-consumers"=>{
              "data"=>[]
            },
            "localpool-processing-contract"=>{
              "data"=>nil
            },
            "metering-point-operator-contract"=>{
              "data"=>nil
            }
          }
        }
      }
    end

    let(:admin_group_json) do
      json = group_json.dup
      json['data']['attributes']['updatable']=true
      json['data']['attributes']['deletable']=true
      json
    end

    let(:empty_json) do
      {
        'data'=>[]
      }
    end

    let(:groups_json) do
      group_data = group_json['data'].dup
      group_data['attributes']['updatable'] = false
      group_data['attributes']['deletable'] = false
      group_data['relationships']['managers']['data'] = []
      {
        'data'=>[
          group_data
        ]
      }
    end

    let(:admin_groups_json) do
      group_data = group_json['data'].dup
      {
        'data'=>[
          group_data
        ]
      }
    end

    it '403' do
      localpool.update(readable: :member)
      GET "/api/v1/groups/#{localpool.id}"
      expect(response).to have_http_status(403)
      expect(json).to eq anonymous_denied_json

      tribe.update(readable: :member)
      GET "/api/v1/groups/#{tribe.id}", user
      expect(response).to have_http_status(403)
      expect(json).to eq denied_json
    end

    it '404' do
      GET "/api/v1/groups/bla-blub"
      expect(response).to have_http_status(404)
      expect(json).to eq anonymous_not_found_json

      GET "/api/v1/groups/bla-blub", admin
      expect(response).to have_http_status(404)
      expect(json).to eq not_found_json
    end

    it '200' do
      GET "/api/v1/groups/#{group.id}", user
      expect(response).to have_http_status(200)
      expect(json).to eq group_json

      GET "/api/v1/groups/#{group.id}", admin
      expect(response).to have_http_status(200)
      expect(json).to eq admin_group_json
    end

    it '200 all' do
      group.update(readable: :member)

      GET "/api/v1/groups"
      expect(response).to have_http_status(200)
      expect(json.to_yaml).to eq empty_json.to_yaml

      GET "/api/v1/groups", user
      expect(response).to have_http_status(200)
      expect(json.to_yaml).to eq groups_json.to_yaml

      GET "/api/v1/groups", admin
      expect(response).to have_http_status(200)
      expect(json.to_yaml).to eq admin_groups_json.to_yaml
    end

    it '200 all filtered' do
      group.update(readable: :member)

      GET "/api/v1/groups"
      expect(response).to have_http_status(200)
      expect(json.to_yaml).to eq empty_json.to_yaml

      GET "/api/v1/groups", user, filter: 'blabla'
      expect(response).to have_http_status(200)
      expect(json.to_yaml).to eq empty_json.to_yaml

      GET "/api/v1/groups", other, filter: group.name
      expect(response).to have_http_status(200)
      expect(json.to_yaml).to eq empty_json.to_yaml

      GET "/api/v1/groups", user, filter: group.name
      expect(response).to have_http_status(200)
      expect(json.to_yaml).to eq groups_json.to_yaml

      GET "/api/v1/groups", admin, filter: 'blabla'
      expect(response).to have_http_status(200)
      expect(json.to_yaml).to eq empty_json.to_yaml

      GET "/api/v1/groups", admin, filter: group.name
      expect(response).to have_http_status(200)
      expect(json.to_yaml).to eq admin_groups_json.to_yaml

    end
  end

  context 'meters' do

    context 'GET' do
      it '403' do
        localpool.update(readable: :member)
        GET "/api/v1/groups/#{localpool.id}/meters"
        expect(response).to have_http_status(403)
        expect(json).to eq anonymous_denied_json

        tribe.update(readable: :member)
        GET "/api/v1/groups/#{tribe.id}/meters", user
        expect(response).to have_http_status(403)
        expect(json).to eq denied_json
      end

      it '404' do
        GET "/api/v1/groups/bla-blub/meters", admin
        expect(response).to have_http_status(404)
        expect(json).to eq not_found_json
      end

      [:tribe, :localpool].each do |type|
        context "as #{type}" do

          let(:group) { send type }

          let!(:meters) do
            2.times.collect do
              meter = Fabricate(:meter)
              meter.registers.each do |r|
                r.group = group
                r.save
              end
              meter
            end
            group.meters
          end

          let(:meter_json) do
            {
              "data"=>meters.collect do |meter|
                json =
                  {
                    "id"=>meter.id,
                    "type"=>"meter-#{meter.is_a?(Meter::Virtual) ? 'virtuals': 'reals'}",
                    "attributes"=>{
                      "type"=>"meter_#{meter.is_a?(Meter::Virtual) ? 'virtual': 'real'}",
                      "manufacturer-name"=>meter.manufacturer_name,
                      "manufacturer-product-name"=>meter.manufacturer_product_name,
                      "manufacturer-product-serialnumber"=>meter.manufacturer_product_serialnumber,
                      "metering-type"=>meter.metering_type,
                      "meter-size"=>meter.meter_size,
                      "ownership"=>meter.owner,
                      "direction-label"=>meter.direction,
                      "build-year"=>meter.build_year ? meter.build_year.to_s : nil,
                      "updatable"=>false,
                      "deletable"=>false
                    }
                  }
                if meter.is_a? Meter::Real
                  json['attributes']['smart'] = false
                  json["relationships"]= {
                    "registers"=>{
                      # NOTE not sure why it renders empty array here
                      "data"=>[]
                    }
                  }
                else
                  json["relationships"]= {
                    "register"=>{
                      "data"=>
                      {
                        "id"=>meter.register.id,
                        "type"=>'register-virtuals'
                      }
                    }
                  }
                end
                json
              end
            }
          end

          it '200' do
            GET "/api/v1/groups/#{group.id}/meters", admin

            expect(response).to have_http_status(200)
            expect(json.to_yaml).to eq(meter_json.to_yaml)
          end
        end
      end
    end
  end











  let(:page_overload) { 33 }

  let(:output_register_with_manager) do
    register = Fabricate(:output_meter).output_register
    Fabricate(:user).add_role(:manager, register)
    register
  end

  it 'gets the related registers for Group' do
    group = Fabricate(:tribe)
    r = Fabricate(:input_meter).input_register
    r.update(readable: :world)
    group.registers << r
    r = Fabricate(:output_meter).output_register
    r.update(readable: :community)
    group.registers << r
    r = Fabricate(:input_meter).input_register
    r.update(readable: :friends)
    group.registers << r
    r = Fabricate(:input_meter).input_register
    r.update(readable: :members)
    group.registers << r
    r = Fabricate(:output_meter).output_register
    r.update(readable: :world)
    group.registers << r

    get_without_token "/api/v1/groups/#{group.id}/registers"
    expect(response).to have_http_status(200)
    expect(json['data'].size).to eq(5)
  end



  [nil, :sufficiency, :closeness, :autarchy, :fitting].each do |mode|

    it "fails the related scores without interval using mode #{mode}" do
      group                 = Fabricate(:tribe)
      now                   = Time.current - 2.days
      params = { mode: mode, timestamp: now }
      get_without_token "/api/v1/groups/#{group.id}/scores", params
      expect(response).to have_http_status(422)
      expect(json['errors'].first['source']['pointer']).to eq '/data/attributes/interval'
    end

    [:day, :month, :year].each do |interval|
      it "fails the related #{interval}ly scores without timestamp using mode #{mode}" do
        group                 = Fabricate(:tribe)
        params = { mode: mode, interval: interval }
        get_without_token "/api/v1/groups/#{group.id}/scores", params
        expect(response).to have_http_status(422)
        expect(json['errors'].first['source']['pointer']).to eq '/data/attributes/timestamp'
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
        expect(json['data'].size).to eq(5)
        sample = json['data'].first['attributes']
        expect(sample['mode']).to eq((mode || 'autarchy').to_s)
        expect(sample['interval']).to eq(interval.to_s)
        expect(sample['interval-beginning'] < now.as_json && now.as_json < sample['interval-end']).to eq true
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
    expect(json['data'].size).to eq(page_overload)
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
    expect(json['data'].size).to eq(page_overload)
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
    expect(json['data'].size).to eq(page_overload)

    access_token  = Fabricate(:full_access_token_as_admin)
    get_with_token "/api/v1/groups/#{group.id}/managers", access_token.token
    expect(response).to have_http_status(200)
    expect(json['data'].size).to eq(page_overload * 2)
  end

  it 'get all members' do
    access_token  = Fabricate(:simple_access_token)
    group         = Fabricate(:tribe_with_members_readable_by_world, members: page_overload * 2)

    group.members[0..page_overload].each do |u|
      u.profile.update(readable: 'world')
    end

    get_with_token "/api/v1/groups/#{group.id}/members", access_token.token
    expect(response).to have_http_status(200)
    expect(json['data'].size).to eq(page_overload + 1)

    access_token  = Fabricate(:full_access_token_as_admin)
    get_with_token "/api/v1/groups/#{group.id}/members", access_token.token
    expect(response).to have_http_status(200)
    expect(json['data'].size).to eq(page_overload * 2)
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
    expect(json['data'].size).to eq(0)

    manager = User.find(access_token.resource_owner_id)
    manager.add_role(:manager, register_in)
    manager.add_role(:member, register_out)

    get_with_token "/api/v1/groups/#{group.id}/energy-consumers", access_token.token
    expect(response).to have_http_status(200)
    expect(json['data'].size).to eq(1)
  end


  it 'gets the related metering_point_operator_contract for the localpool only with full token' do
    group  = Fabricate(:localpool_forstenried)
    mpoc_forstenried = Fabricate(:mpoc_forstenried, signing_user: Fabricate(:user), localpool: group, customer: Fabricate(:user))

    full_access_token = Fabricate(:full_access_token)
    get_with_token "/api/v1/groups/localpools/#{group.id}/metering-point-operator-contract", full_access_token.token
    expect(response).to have_http_status(403)

    manager_access_token = Fabricate(:full_access_token)
    manager_user          = User.find(manager_access_token.resource_owner_id)
    manager_user.add_role(:manager, group)
    get_with_token "/api/v1/groups/localpools/#{group.id}/metering-point-operator-contract", manager_access_token.token
    expect(response).to have_http_status(200)

    expect(json['data']['id']).to eq(group.metering_point_operator_contract.id)
    expect(json['data']['type']).to eq('contract-metering-point-operators')
  end


  it 'gets the related localpool-processing-contract for the localpool only with full token' do
    group  = Fabricate(:localpool_forstenried)
    lpc_forstenried = Fabricate(:lpc_forstenried, signing_user: Fabricate(:user), localpool: group, customer: Fabricate(:user))

    full_access_token = Fabricate(:full_access_token)
    get_with_token "/api/v1/groups/localpools/#{group.id}/localpool-processing-contract", full_access_token.token
    expect(response).to have_http_status(403)

    manager_access_token = Fabricate(:full_access_token)
    manager_user          = User.find(manager_access_token.resource_owner_id)
    manager_user.add_role(:manager, group)
    get_with_token "/api/v1/groups/localpools/#{group.id}/localpool-processing-contract", manager_access_token.token
    expect(response).to have_http_status(200)

    expect(json['data']['id']).to eq(group.localpool_processing_contract.id)
    expect(json['data']['type']).to eq('contract-localpool-processings')
  end



end
