describe "#{Buzzn::Permission} - #{Display::GroupResource}" do

  entity(:admin) { Fabricate(:admin) }
  entity(:mentor) { Fabricate(:user) }
  entity(:other) { Fabricate(:user) }
  let(:anonymous) { nil }

  entity!(:tribe) do
    group = Fabricate(:tribe, show_display_app: true)
    Fabricate(:real_meter, group: group)
    mentor.person.add_role(Role::GROUP_ENERGY_MENTOR, group)
    group
  end

  entity!(:localpool) do
    group = create(:localpool, show_display_app: true)
    create(:meter, :virtual, group: group)
    mentor.person.add_role(Role::GROUP_ENERGY_MENTOR, group)
    group
  end

  %i(admin mentor other anonymous).each do |user|
    context "user<#{user}>" do
      let(:all) { Display::GroupResource.all(send(user)) }
      it 'all - groups' do
        expect(all.collect { |l| l.object }).to match_array [tribe, localpool]
      end

      %i(tribe localpool).each do |type|
        context "group<#{type}>" do
          let(:group) { all.retrieve(send(type).id) }

          it 'retrieve' do
            expect(group.object).to eq send(type)
          end

          it 'update' do
            expect(group.updatable?).to be false
          end

          it 'delete' do
            expect(group.deletable?).to be false
          end

          context 'registers' do
            let(:registers) { group.registers }

            it 'all' do
              expect(registers.collect { |l| l.object }).to match_array group.object.registers.consumption_production
            end
            let(:register) { registers.retrieve(registers.first.id) }

            it 'retrieve' do
              expect(register.object).to eq registers.first.object
            end

            it 'update' do
              expect(register.updatable?).to be false
            end

            it 'delete' do
              expect(register.deletable?).to be false
            end
          end

          context 'mentors' do
            let(:mentors) { group.mentors }

            it 'all' do
              expect(mentors.collect{ |l| l.object }).to match_array group.object.mentors.collect {|m| m }
            end
            let(:actual_mentor) { mentors.retrieve(mentors.first.id) }

            it 'retrieve' do
              expect(actual_mentor.object).to eq mentors.first.object
            end

            it 'update' do
              expect(actual_mentor.updatable?).to be false
            end

            it 'delete' do
              expect(actual_mentor.deletable?).to be false
            end
          end
        end
      end
    end
  end
end
