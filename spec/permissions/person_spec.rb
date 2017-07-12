# coding: utf-8
describe PersonPermissions do

  entity(:admin) { Fabricate(:admin) }
  entity(:me) { Fabricate(:user) }
  let(:anonymous) { nil }

  [:admin, :me, :anonymous].each do |user|
    
    context "user<#{user}>" do

      let(:all) { PersonResource.all(send(user)) }

      it "all" do
        if user != :anonymous
          expect(all.collect { |l| l.object }).to match_array [send(user).person]
        else
          expect(all.collect { |l| l.object }).to eq []
        end
      end

      it "retrieve" do
        case user
        when :anonymous
          expect { all.retrieve(me.person.id) }.to raise_error Buzzn::PermissionDenied
        when :admin
          expect { all.retrieve(me.person.id) }.to raise_error Buzzn::PermissionDenied
          expect(all.retrieve(admin.person.id).object).to eq admin.person
        when :me
          expect { all.retrieve(admin.person.id) }.to raise_error Buzzn::PermissionDenied
          expect(all.retrieve(me.person.id).object).to eq me.person          
        end
      end

      it 'update' do
        if user != :anonymous
          expect { all.retrieve(send(user).person.id).update({}) }.not_to raise_error
        end
      end
    
      it 'delete' do
        if user != :anonymous
          expect { all.retrieve(me.person.id).delete }.to raise_error Buzzn::PermissionDenied
        end
      end
    end
  end
end
