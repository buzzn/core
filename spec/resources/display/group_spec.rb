describe Display::GroupResource do

  entity(:admin) { Fabricate(:admin) }

  entity!(:tribe) do
    group = Fabricate(:tribe, show_display_app: true)
    create(:meter, :real, group: group)
    admin.person.add_role(Role::GROUP_ENERGY_MENTOR, group)
    group
  end

  entity!(:localpool) do
    group = create(:localpool, show_display_app: true)
    create(:meter, :virtual, group: group)
    admin.person.add_role(Role::GROUP_ENERGY_MENTOR, group)
    group
  end

  entity(:tribe_resource) do
    Display::GroupResource.all(admin).retrieve(tribe.id)
  end

  entity(:localpool_resource) do
    Display::GroupResource.all(admin).retrieve(localpool.id)
  end

  entity(:group) { [tribe, localpool].sample }

  entity(:resource) do
    Display::GroupResource.all(admin).retrieve(group.id)
  end

  let(:resources) { Display::GroupResource.all(admin) }

  let(:attributes) do ['id',
                       'type',
                       'updated_at',
                       'name',
                       'slug',
                       'description'] end

  it 'retrieve' do
    [tribe, localpool].each do |grp|
      attrs = resources.retrieve(grp.id).to_h
      expect(attrs.keys).to match_array attributes
    end
  end

  it 'retrieve - all' do
    expected = {'group_tribe' => tribe.id, 'group_localpool' => localpool.id}
    result = resources.collect do |r|
      expect(r.class).to eq Display::GroupResource
      [r.type, r.id]
    end
    expect(Hash[result]).to eq expected
  end

  describe 'registers' do
    let(:attributes) do ['id',
                         'type',
                         'updated_at',
                         'direction',
                         'name',
                         'label'] end
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
        resource = send("#{type}_resource")
        expect(resource.registers.size).to eq 1
        resource.registers.each do |reg|
          expect(reg.class).to eq Display::RegisterResource
          expect(reg.type).to eq (reg.object.is_a?(Register::Real) ? 'register_real' : 'register_virtual')
          expect(reg.to_h.keys).to eq attributes
        end
      end
    end
  end

  describe 'mentors' do
    let(:attributes) do ['id',
                         'type',
                         'updated_at',
                         'title',
                         'first_name',
                         'last_name',
                         'image'] end

    it 'retrieve' do
      expect(resource.mentors.retrieve(admin.person.id).object).to eq admin.person
    end

    it 'retrieve - all' do
      expect(resource.mentors.size).to eq 1
      resource.mentors.each do |reg|
        expect(reg.class).to eq Display::MentorResource
        expect(reg.type).to eq 'person'
        expect(reg.to_h.keys).to eq attributes
      end
    end
  end
end
