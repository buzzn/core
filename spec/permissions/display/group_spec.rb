# coding: utf-8
describe "#{Buzzn::Permission} - #{Display::GroupResource}" do

  entity(:admin) { Fabricate(:admin) }
  entity(:manager) { Fabricate(:user) }
  entity(:other) { Fabricate(:user) }
  let(:anonymous) { nil }

  entity!(:tribe) do
    group = Fabricate(:tribe)
    Fabricate(:real_meter).registers.first.update(group: group)
    manager.person.add_role(Role::GROUP_ADMIN, group)
    group
  end

  entity!(:localpool)  do
    group = Fabricate(:localpool)
    Fabricate(:virtual_meter).register.update(group: group)
    manager.person.add_role(Role::GROUP_ADMIN, group)
    group
  end

  [:admin, :manager, :other, :anonymous].each do |user|
    context "user<#{user}>" do
      let(:all) { Display::GroupResource.all(send(user)) }
      it "all - groups" do
        expect(all.collect { |l| l.object }).to match_array [tribe, localpool]
      end

      [:tribe, :localpool].each do |type|
        context "group<#{type}>" do
          let(:group) { all.retrieve(send(type).id) }

          it "retrieve" do
            expect(group.object).to eq send(type)
          end

          it 'update' do
            expect { group.update({}) }.to raise_error Buzzn::PermissionDenied
          end

          it 'delete' do
            expect { group.delete }.to raise_error Buzzn::PermissionDenied
          end

          context 'registers' do
            let(:registers) { group.registers }

            it 'all' do
              expect(registers.collect { |l| l.object }).to match_array group.object.registers.consumption_production
            end
            let(:register) { registers.retrieve(registers.first.id) }

            it "retrieve" do
              expect(register.object).to eq registers.first.object
            end

            it 'update' do
              expect { register.update({}) }.to raise_error Buzzn::PermissionDenied
            end

            it 'delete' do
              expect { register.delete }.to raise_error Buzzn::PermissionDenied
            end
          end

          context 'mentors' do
            let(:mentors) { group.mentors }

            it 'all' do
              expect(mentors.collect{ |l| l.object }).to match_array group.object.managers.collect {|m| m }
            end
            let(:mentor) { mentors.retrieve(mentors.first.id) }

            it "retrieve" do
              expect(mentor.object).to eq mentors.first.object
            end

            it 'update' do
              expect { mentor.update({}) }.to raise_error Buzzn::PermissionDenied
            end

            it 'delete' do
              expect { mentor.delete }.to raise_error Buzzn::PermissionDenied
            end
          end

          context 'scores' do
            let(:scores) { group.scores(interval: :day) }
            it "retrieve" do
              expect(scores.to_a).to eq []
            end
          end
        end
      end
    end
  end
end
