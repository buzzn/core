describe Display::GroupRoda do

  def app
    Display::GroupRoda # this defines the active application for this test
  end

  let(:not_found_json) do
    {
      "errors" => [
        {
          "detail"=>"Group::Base: bla-blub not found"
        }
      ]
    }
  end

  entity!(:tribe) { Fabricate(:tribe, show_display_app: true) }

  entity!(:localpool) { Fabricate(:localpool, show_display_app: false) }

  entity!(:group) do
    group = Fabricate(:localpool, show_display_app: true)
    $user.person.reload.add_role(Role::GROUP_ENERGY_MENTOR, group)
    group
  end

  let(:empty_json) { [] }

  context 'GET' do

    let(:group_json) do
      {
        "id"=>group.id,
        "type"=>"group_localpool",
        'updated_at'=>group.updated_at.as_json,
        "name"=>group.name,
        "slug"=>group.slug,
        "description"=>group.description,
        "mentors"=> {
          "array" => group.mentors.collect do |manager|
            {
              "id"=>manager.id,
              "type"=>"person",
              'updated_at'=>manager.updated_at.as_json,
              "title"=>manager.attributes['title'],
              "first_name"=>manager.first_name,
              "last_name"=>manager.last_name,
              "image"=>manager.image.medium.url
            }
          end
        }
      }
    end

    let(:groups_json) do
      Group::Base.where(show_display_app: true).collect do |group|
        if group.is_a? Group::Tribe
          type = :tribe
        else
          type = :localpool
        end
        {
          "id"=>group.id,
          "type"=>"group_#{type}",
          'updated_at'=>group.updated_at.as_json,
          "name"=>group.name,
          "slug"=>group.slug,
          "description"=>group.description,
          "mentors"=> {
            'array' => group.mentors.collect do |manager|
              {
                "id"=>manager.id,
                "type"=>"person",
                'updated_at'=>manager.updated_at.as_json,
                "title"=>manager.attributes['title'],
                "first_name"=>manager.first_name,
                "last_name"=>manager.last_name,
                "image"=>manager.image.medium.url
              }
            end
          }
        }
      end
    end

    it '404' do
      GET "/bla-blub", nil
      expect(response).to have_http_status(404)
      expect(json).to eq not_found_json
    end

    it '403' do
      group.update(show_display_app: false)
      begin
        GET "/#{group.id}", nil
        expect(response).to have_http_status(403)
      ensure
        group.update(show_display_app: true)
      end
    end

    it '200' do
      GET "/#{group.id}", nil, include: :mentors
      expect(response).to have_http_status(200)
      expect(json.to_yaml).to eq group_json.to_yaml

      GET "/#{group.slug}", nil, include: :mentors
      expect(response).to have_http_status(200)
      expect(json.to_yaml).to eq group_json.to_yaml
    end

    it '200 all' do
      GET "", nil, include: :mentors
      expect(response).to have_http_status(200)
      expect(sort(json['array']).to_yaml).to eq sort(groups_json).to_yaml
    end
  end

  context 'mentors' do

    context 'GET' do

      it '404' do
        GET "/bla-blub/mentors", nil
        expect(response).to have_http_status(404)
        expect(json).to eq not_found_json
      end

      entity(:mentor) { Fabricate(:user).person }

      let(:group) do
        group = tribe
        mentor.add_role(Role::GROUP_ENERGY_MENTOR, group)
        group
      end

      let(:mentors_json) do
        [
          {
            "id"=>mentor.id,
            "type"=>"person",
            'updated_at'=>mentor.updated_at.as_json,
            "title"=>mentor.attributes['title'],
            "first_name"=>mentor.first_name,
            "last_name"=>mentor.last_name,
            "image"=>mentor.image.medium.url,
          }
        ]
      end

      it "200" do
        GET "/#{group.id}/mentors", nil

        expect(response).to have_http_status(200)
        expect(json['array'].to_yaml).to eq(mentors_json.to_yaml)
      end
    end
  end

  context 'scores' do

    context 'GET' do

      entity(:group) { tribe }

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
      entity(:interval) { intervals.sample }
      entity!(:scores) do
        interval_information = Buzzn::ScoreCalculator.new(nil, now).send(:interval, interval)
        5.times do
          Score.create(mode: mode, interval: interval_information[0], interval_beginning: interval_information[1], interval_end: interval_information[2], value: 10, scoreable_type: 'Group::Base', scoreable_id: group.id)
        end
        interval_information = Buzzn::ScoreCalculator.new(nil, Time.new(0)).send(:interval, interval)
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
        GET "/#{group.id}/scores", nil

        expect(response).to have_http_status(422)
        expect(json.to_yaml).to eq(missing_json.to_yaml)
      end

      it '422 wrong' do
        GET "/#{group.id}/scores", nil,
            interval: :today,
            timestamp: 'today',
            mode: :any

        expect(response).to have_http_status(422)
        expect(json.to_yaml).to eq(wrong_json.to_yaml)
      end

      it '200' do
        GET "/#{group.id}/scores", nil,
            interval: intervals.sample,
            timestamp: Time.current - 10.years

        expect(json['array'].to_yaml).to eq(empty_json.to_yaml)
        expect(response).to have_http_status(200)

        GET "/#{group.id}/scores", nil,
            interval: intervals.sample,
            timestamp: Time.current - 10.years,
            mode: modes.sample

        expect(json['array'].to_yaml).to eq(empty_json.to_yaml)
        expect(response).to have_http_status(200)

        GET "/#{group.id}/scores", nil,
            interval: interval,
            timestamp: now,
            mode: mode

        expect(json['array'].to_yaml).to eq(scores_json.to_yaml)
        expect(response).to have_http_status(200)
      end
    end
  end
end
