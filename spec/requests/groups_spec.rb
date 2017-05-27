describe "groups" do

  def app
    GroupRoda # this defines the active application for this test
  end

  entity(:admin) { Fabricate(:admin_token) }

  entity(:user) { Fabricate(:user_token) }

  entity(:other) { Fabricate(:user_token) }

  let(:not_found_json) do
    {
      "errors" => [
        {
          "detail"=>"Group::Base: bla-blub not found by User: #{admin.resource_owner_id}"
        }
      ]
    }
  end

  entity!(:tribe) { Fabricate(:tribe) }

  entity!(:localpool) { Fabricate(:localpool) }

  entity!(:group) do
    group = Fabricate(:localpool)
    User.find(user.resource_owner_id).add_role(:manager, group)
    group
  end

  let(:empty_json) { [] }

  context 'GET' do

    let(:group_json) do
      {
        "id"=>group.id,
        "type"=>"group_localpool",
        "name"=>group.name,
        "description"=>group.description,
        "readable"=>group.readable,
        "updatable"=>true,
        "deletable"=>true,
        "meters"=>group.meters.collect do |meter|
          json = {
            "id"=>meter.id,
            'type'=>'meter_virtual',
            "manufacturer_name"=>meter.manufacturer_name,
            "manufacturer_product_name"=>meter.manufacturer_product_name,
            "manufacturer_product_serialnumber"=>meter.manufacturer_product_serialnumber,
            "metering_type"=>meter.metering_type,
            "meter_size"=>meter.meter_size,
            "ownership"=>meter.ownership,
            "direction_label"=>meter.direction,
            "build_year"=>meter.build_year ? meter.build_year.to_s : nil,
            "updatable"=>false,
            "deletable"=>false,
          }
          json['smart'] = true if meter.is_a? Meter::Real
          json
        end,
        "managers"=>group.managers.collect do |manager|
          {
            "id"=>manager.id,
            "type"=>"user",
            "user_name"=>manager.user_name,
            "title"=>manager.profile.title,
            "first_name"=>manager.first_name,
            "last_name"=>manager.last_name,
            "gender"=>manager.profile.gender,
            "phone"=>manager.profile.phone,
            "email"=>manager.email,
            "updatable"=>true,
            "deletable"=>true
          }
        end,
      }
    end

    let(:admin_group_json) do
      json = group_json.dup
      json['updatable']=true
      json['deletable']=true
      json['meters'].each do |meter|
        meter['updatable'] = true
        meter['deletable'] = true
      end
      json
    end

    let(:groups_json) do
      group_data = group_json.dup
      group_data['readable'] = 'member'
      [
        group_data
      ]
    end

    let(:filtered_admin_groups_json) do
      group_data = admin_group_json.dup
      group_data['readable'] = 'member'
      [
        group_data
      ]
    end

    let(:admin_groups_json) do
      Group::Base.all.collect do |group|
        rel = {}
        if group.is_a? Group::Tribe
          type = :tribe
        else
          type = :localpool
        end
        json = {
          "id"=>group.id,
          "type"=>"group_#{type}",
          "name"=>group.name,
          "description"=>group.description,
          "readable"=>group.readable,
          "updatable"=>true,
          "deletable"=>true,
          "meters"=>group.meters.collect do |meter|
            json = {
              "id"=>meter.id,
              'type'=>meter.class.to_s.downcase.sub('::', '_'),
              "manufacturer_name"=>meter.manufacturer_name,
              "manufacturer_product_name"=>meter.manufacturer_product_name,
              "manufacturer_product_serialnumber"=>meter.manufacturer_product_serialnumber,
              "metering_type"=>meter.metering_type,
              "meter_size"=>meter.meter_size,
              "ownership"=>meter.ownership,
              "direction_label"=>meter.direction,
              "build_year"=>meter.build_year ? meter.build_year.to_s : nil,
              "updatable"=>true,
              "deletable"=>true,
            }
            json['smart'] = meter.smart if meter.is_a? Meter::Real
            json
          end,
          "managers"=>group.managers.collect do |manager|
            {
              "id"=>manager.id,
              "type"=>"user",
            "user_name"=>manager.user_name,
            "title"=>manager.profile.title,
            "first_name"=>manager.first_name,
            "last_name"=>manager.last_name,
            "gender"=>manager.profile.gender,
            "phone"=>manager.profile.phone,
            "email"=>manager.email,
            "updatable"=>true,
            "deletable"=>true
            }
          end,
        }.merge(rel)
      end
    end

    it '404' do
      GET "/bla-blub", admin
      expect(response).to have_http_status(404)
      expect(json).to eq not_found_json
    end

    it '200' do
      GET "/#{group.id}?include=meters,managers", user
      expect(response).to have_http_status(200)
      expect(json.to_yaml).to eq group_json.to_yaml

      GET "/#{group.id}?include=meters,managers", admin
      expect(response).to have_http_status(200)
      expect(json.to_yaml).to eq admin_group_json.to_yaml
    end

    it '200 all' do
      begin
        Group::Base.update_all(readable: :member)

        GET ""
        expect(response).to have_http_status(200)
        expect(json.to_yaml).to eq empty_json.to_yaml

        GET "?include=meters,managers", user
        expect(response).to have_http_status(200)
        expect(json.to_yaml).to eq groups_json.to_yaml

        GET "?include=meters,managers", admin
        expect(response).to have_http_status(200)
        expect(json.sort {|n,m| n['id'] <=> m['id']}.to_yaml).to eq admin_groups_json.sort {|n,m| n['id'] <=> m['id']}.to_yaml
      ensure
        Group::Base.update_all(readable: :world)
      end
    end

    it '200 all filtered' do
      begin
        Group::Base.update_all(readable: :member)

        GET ""
        expect(response).to have_http_status(200)
        expect(json.to_yaml).to eq empty_json.to_yaml

        GET "", user, filter: 'blabla'
        expect(response).to have_http_status(200)
        expect(json.to_yaml).to eq empty_json.to_yaml

        GET "", other, filter: group.name
        expect(response).to have_http_status(200)
        expect(json.to_yaml).to eq empty_json.to_yaml

        GET "?include=meters,managers", user, filter: group.name
        expect(response).to have_http_status(200)
        expect(json.to_yaml).to eq groups_json.to_yaml

        GET "", admin, filter: 'blabla'
        expect(response).to have_http_status(200)
        expect(json.to_yaml).to eq empty_json.to_yaml

        GET "?include=meters,managers", admin, filter: group.name
        expect(response).to have_http_status(200)
        expect(json.to_yaml).to eq filtered_admin_groups_json.to_yaml
      ensure
        Group::Base.update_all(readable: :world)
      end
    end
  end

  context 'mentors' do

    context 'GET' do

      it '404' do
        GET "/bla-blub/mentors", admin
        expect(response).to have_http_status(404)
        expect(json).to eq not_found_json
      end

      entity(:mentor) { Fabricate(:user) }
      let(:group) do
        group = send [:tribe, :localpool].sample
        mentor.add_role(:manager, group)
        group
      end

      let(:mentors_json) do
        [
          {
            "id"=>mentor.id,
            "type"=>"user",
            "first_name"=>mentor.profile.first_name,
            "last_name"=>mentor.profile.last_name,
            "image"=>mentor.image.md.url,
          }
        ]
      end

      it "200" do
        GET "/#{group.id}/mentors", admin
          
        expect(response).to have_http_status(200)
        expect(json.to_yaml).to eq(mentors_json.to_yaml)
      end
    end
  end

  context 'scores' do

    context 'GET' do

      entity(:group) { send [:tribe, :localpool].sample }

      let(:missing_json) do
        {
          "errors"=>[
            {"parameter"=>"interval", "detail"=>"is missing"},
            {"parameter"=>"timestamp", "detail"=>"is missing"}
          ]
        }
      end

      let(:wrong_json) do
        {
          "errors"=>[
            {"parameter"=>"interval", "detail"=>"must be one of: year, month, day"},
            {"parameter"=>"timestamp", "detail"=>"must be a time"},
            {"parameter"=>"mode", "detail"=>"must be one of: sufficiency, closeness, autarchy, fitting"}
          ]
        }
      end

      entity(:modes) { [:sufficiency, :closeness, :autarchy, :fitting] }
      entity(:mode) { modes.sample }
      entity(:now) { Time.current - 2.days }
      entity(:intervals) { [:day, :month, :year] }
      entity(:interval) { intervals.sample.to_s }
      entity!(:scores) do
        interval_information = Group::Base.score_interval(interval, now.to_i)
        5.times do
          Score.create(mode: mode, interval: interval_information[0], interval_beginning: interval_information[1], interval_end: interval_information[2], value: 10, scoreable_type: 'Group::Base', scoreable_id: group.id)
        end
        interval_information = Group::Base.score_interval(interval, 0)
        Score.create(mode: mode, interval: interval_information[0], interval_beginning: interval_information[1], interval_end: interval_information[2], value: 3, scoreable_type: 'Group::Base', scoreable_id: group.id)
      end

      let(:scores_json) do
        Score.where("interval_beginning > ?", Time.at(0)).collect do |score|
          {
            "mode"=>score.mode,
            "interval"=>score.interval,
            "interval_beginning"=>score.interval_beginning.iso8601(3),
            "interval_end"=>score.interval_end.iso8601(3),
            "value"=>score.value
          }
        end
      end

      it '422 missing' do
        GET "/#{group.id}/scores", admin

        expect(response).to have_http_status(422)
        expect(json.to_yaml).to eq(missing_json.to_yaml)
      end

      it '422 wrong' do
        GET "/#{group.id}/scores", admin,
            interval: :today,
            timestamp: 'today',
            mode: :any

        expect(response).to have_http_status(422)
        expect(json.to_yaml).to eq(wrong_json.to_yaml)
      end

      it '200' do
        GET "/#{group.id}/scores", admin,
            interval: intervals.sample,
            timestamp: Time.current - 10.years

        expect(json.to_yaml).to eq(empty_json.to_yaml)
        expect(response).to have_http_status(200)

        GET "/#{group.id}/scores", admin,
            interval: intervals.sample,
            timestamp: Time.current - 10.years,
            mode: modes.sample

        expect(json.to_yaml).to eq(empty_json.to_yaml)
        expect(response).to have_http_status(200)

        GET "/#{group.id}/scores", admin,
            interval: interval,
            timestamp: now,
            mode: mode

        expect(json.to_yaml).to eq(scores_json.to_yaml)
        expect(response).to have_http_status(200)
      end
    end
  end
end
