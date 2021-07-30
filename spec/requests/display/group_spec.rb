describe Display::GroupRoda, :request_helper do

  def app
    Display::GroupRoda # this defines the active application for this test
  end

  entity!(:tribe) { create(:group, :tribe, show_display_app: true) }

  entity!(:localpool) { create(:group, :localpool, show_display_app: false) }

  entity!(:group) do
    group = create(:group, :localpool, show_display_app: true)
    $user.person.reload.add_role(Role::GROUP_ENERGY_MENTOR, group)
    group
  end

  context 'GET' do

    let(:group_json) do
      {
        'id'=>group.id,
        'type'=>'group_localpool',
        'created_at'=>group.created_at.as_json,
        'updated_at'=>group.updated_at.as_json,
        'name'=>group.name,
        'slug'=>group.slug,
        'description'=>group.description,
        'mieterstromzuschlag'=>false,
        'mentors'=> {
          'array' => group.mentors.collect do |manager|
            {
              'id'=>manager.id,
              'type'=>'person',
              'created_at'=>manager.created_at.as_json,
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
          'created_at'=>group.created_at.as_json,
          'updated_at'=>group.updated_at.as_json,
          'name'=>group.name,
          'slug'=>group.slug,
          'description'=>group.description,
          'mieterstromzuschlag'=>false,
          'mentors'=> {
            'array' => group.mentors.collect do |manager|
              {
                'id'=>manager.id,
                'type'=>'person',
                'created_at'=>manager.created_at.as_json,
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
            'created_at'=>mentor.created_at.as_json,
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
