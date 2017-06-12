# coding: utf-8
describe Display::GroupResource do

  entity(:user) { Fabricate(:admin) }

  entity!(:tribe) do
    group = Fabricate(:tribe)
    Fabricate(:real_meter).registers.first.update(group: group)
    user.add_role(:manager, group)
    group
  end

  entity!(:localpool)  do
    group = Fabricate(:localpool)
    Fabricate(:virtual_meter).register.update(group: group)
    user.add_role(:manager, group)
    group
  end

  entity(:tribe_resource) do
    Display::GroupResource.all(user).retrieve(tribe.id)
  end

  entity(:localpool_resource) do
    Display::GroupResource.all(user).retrieve(localpool.id)
  end

  entity(:group) { [tribe, localpool].sample }

  entity(:resource) do
    Display::GroupResource.all(user).retrieve(group.id)
  end

  let(:attributes) { ['id',
                      'type',
                      'name',
                      'description'] }


  it 'retrieve' do
    [tribe, localpool].each do |grp|
      attrs = Display::GroupResource.all(user).retrieve(grp.id).to_h
      expect(attrs.keys).to match_array attributes
    end
  end

  it 'retrieve - all' do
    expected = {'group_tribe' => tribe.id, 'group_localpool' => localpool.id}
    result = Display::GroupResource.all(user).collect do |r|
      expect(r.class).to eq Display::GroupResource
      [r.type, r.id]
    end
    expect(Hash[result]).to eq expected
  end

  describe 'registers' do
    let(:attributes) { ['id',
                        'type',
                        'direction',
                        'name',
                        'label'] }
    it 'retrieve' do
      [:tribe, :localpool].each do |type|
        group = send(type)
        resource = send("#{type}_resource")
        first = group.registers.consumption_production.first
        expect(resource.registers.retrieve(first.id).object).to eq first
      end
    end

    it 'retrieve - all' do
      [:tribe, :localpool].each do |type|
        group = send(type)
        resource = send("#{type}_resource")
        expect(resource.registers.size).to eq 1
        resource.registers.each do |reg|
          expect(reg.class).to eq Display::RegisterResource
          expect(reg.type).to eq (reg.object.is_a?(Register::Real) ? 'register_real' : 'register_virtual')
          expect(reg.to_h.keys).to eq attributes
        end
      end
    end

    it 'update' do
      expect{ resource.registers.first.update({}) }.to raise_error Buzzn::PermissionDenied
    end

    it 'delete' do
      expect{ resource.registers.first.delete }.to raise_error Buzzn::PermissionDenied
    end
  end

  describe 'mentors' do
    let(:attributes) { ['id',
                        'type',
                        'title',
                        'first_name',
                        'last_name',
                        'image'] }
    
    it 'retrieve' do
      expect(resource.mentors.retrieve(user.id).object).to eq user
    end

    it 'retrieve - all' do
      expect(resource.mentors.size).to eq 1
      resource.mentors.each do |reg|
        expect(reg.class).to eq Display::MentorResource
        expect(reg.type).to eq 'user'
        expect(reg.to_h.keys).to eq attributes
      end
    end

    it 'update' do
      expect{ resource.mentors.first.update({}) }.to raise_error Buzzn::PermissionDenied
    end

    it 'delete' do
      expect{ resource.mentors.first.delete }.to raise_error Buzzn::PermissionDenied
    end
  end

  describe 'scores' do

    [:day, :month, :year].each do |interval|
      describe interval do

        before { Score.delete_all }

        [:sufficiency, :closeness, :autarchy, :fitting].each do |type|

          describe type do

            let!(:out_of_range) do
                begin
                  interval_information  = Group::Base.score_interval(interval.to_s, 123123)
                  Score.create(mode: type, interval: interval_information[0], interval_beginning: interval_information[1], interval_end: interval_information[2], value: (rand * 10).to_i, scoreable_type: Group::Base, scoreable_id: group.id)
                end
            end

            let!(:in_range) do
                begin
                  interval_information  = Group::Base.score_interval(interval.to_s, Time.current.yesterday.to_i)
                  Score.create(mode: type, interval: interval_information[0], interval_beginning: interval_information[1], interval_end: interval_information[2], value: (rand * 10).to_i, scoreable_type: Group::Base, scoreable_id: group.id)
                end
            end

            let(:attributes) { ['mode', 'interval', 'interval_beginning', 'interval_end', 'value'] }

            it 'now' do
              result = Display::GroupResource
                         .all(user)
                         .retrieve(group.id)
                         .scores(interval: interval, mode: type)
              expect(result.size).to eq 1
              expect(result.first.to_hash.keys).to match_array attributes
            end

            it 'yesterday' do
              result = Display::GroupResource
                         .all(user)
                         .retrieve(group.id)
                         .scores(interval: interval,
                                 mode: type,
                                 timestamp: Time.current.yesterday)
              expect(result.size).to eq 1
              expect(result.first.to_hash.keys).to match_array attributes
            end
          end
        end
      end
    end
  end
end
