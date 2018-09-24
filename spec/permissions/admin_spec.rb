describe "#{Buzzn::Permission} - #{AdminResource}" do

  entity!(:localpool) do
    create(:group, :localpool)
  end
  entity!(:metering_point_operator_contract) do
    create(:contract, :metering_point_operator, localpool: localpool, customer: localpool.owner)
  end

  entity(:operator) { create(:account, :buzzn_operator) }
  entity!(:manager) do
    manager = create(:account)
    manager.person.add_role(Role::GROUP_ADMIN, localpool)
    manager
  end

  let(:anonymous) { nil }

  [:operator, :manager, :anonymous].each do |user|

    context "user<#{user}>" do

      let(:all) { AdminResource.new(send(user)) }

      [:persons, :organizations].each do |type|
        it type do
          all = AdminResource.new(send(user))
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
