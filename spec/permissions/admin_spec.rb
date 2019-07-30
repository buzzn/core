describe "#{Buzzn::Permission} - #{AdminResource}" do

  entity!(:localpool) do
    localpool = Fabricate(:localpool)
    Fabricate(:metering_point_operator_contract, localpool: localpool)
    localpool
  end

  entity(:admin) { Fabricate(:admin) }
  entity(:operator) { Fabricate(:buzzn_operator) }
  entity!(:manager) do
    manager = Fabricate(:user)
    manager.person.add_role(Role::GROUP_ADMIN, localpool)
    manager
  end

  let(:anonymous) { nil }

  [:admin, :operator, :manager, :anonymous].each do |user|

    context "user<#{user}>" do

      let(:all) { AdminResource.new(send(user)) }

      [:persons, :organizations].each do |type|
        it type do
          if user != :anonymous
            expect(all.send(type).collect { |l| l.object }).to match_array Group::Localpool.all.send(type).to_a
          else
            expect(all.send(type).collect { |l| l.object }).to eq []
          end
        end
      end
    end
  end
end
