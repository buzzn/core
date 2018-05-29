describe Display::GroupRoda do

  def app
    Display::GroupRoda # this defines the active application for this test
  end

  let(:not_found_json) do
    {
      'errors' => [
        {
          'detail'=>'Group::Base: bla-blub not found'
        }
      ]
    }
  end

  entity!(:tribe) { create(:group, :tribe, show_display_app: true) }

  entity!(:localpool) { create(:group, :localpool, show_display_app: false) }

  entity!(:group) do
    group = create(:group, :localpool, show_display_app: true)
    $user.person.reload.add_role(Role::GROUP_ENERGY_MENTOR, group)
    group
  end

  let(:empty_json) { [] }

  context 'GET' do

    let(:group_json) do
      {
        'id'=>group.id,
        'type'=>'group_localpool',
        'updated_at'=>group.updated_at.as_json,
        'name'=>group.name,
        'slug'=>group.slug,
        'description'=>group.description,
        'mentors'=> {
          'array' => group.mentors.collect do |manager|
            {
              'id'=>manager.id,
              'type'=>'person',
              'updated_at'=>manager.updated_at.as_json,
              'title'=>manager.attributes['title'],
              'first_name'=>manager.first_name,
              'last_name'=>manager.last_name,
              'image'=>manager.image.medium.url
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
          'id'=>group.id,
          'type'=>"group_#{type}",
          'updated_at'=>group.updated_at.as_json,
          'name'=>group.name,
          'slug'=>group.slug,
          'description'=>group.description,
          'mentors'=> {
            'array' => group.mentors.collect do |manager|
              {
                'id'=>manager.id,
                'type'=>'person',
                'updated_at'=>manager.updated_at.as_json,
                'title'=>manager.attributes['title'],
                'first_name'=>manager.first_name,
                'last_name'=>manager.last_name,
                'image'=>manager.image.medium.url
              }
            end
          }
        }
      end
    end

    it '404' do
      GET '/bla-blub', nil
      expect(response).to have_http_status(404)
      expect(json).to eq not_found_json

      GET "/#{group.slug}123", nil
      expect(response).to have_http_status(404)
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
      GET '', nil, include: :mentors
      expect(response).to have_http_status(200)
      expect(sort(json['array']).to_yaml).to eq sort(groups_json).to_yaml
    end
  end

  context 'mentors' do

    context 'GET' do

      it '404' do
        GET '/bla-blub/mentors', nil
        expect(response).to have_http_status(404)
        expect(json).to eq not_found_json
      end

      entity(:mentor) { create(:account).person }

      let(:group) do
        group = tribe
        mentor.add_role(Role::GROUP_ENERGY_MENTOR, group)
        group
      end

      let(:mentors_json) do
        [
          {
            'id'=>mentor.id,
            'type'=>'person',
            'updated_at'=>mentor.updated_at.as_json,
            'title'=>mentor.attributes['title'],
            'first_name'=>mentor.first_name,
            'last_name'=>mentor.last_name,
            'image'=>mentor.image.medium.url,
          }
        ]
      end

      it '200' do
        GET "/#{group.id}/mentors", nil

        expect(response).to have_http_status(200)
        expect(sort(json['array']).to_yaml).to eq(sort(mentors_json).to_yaml)
      end
    end
  end
end
