require 'buzzn/transactions/admin/localpool/assign_owner'

describe Transactions::Admin::Localpool::OwnerBase do

  entity!(:current) { create(:person) }

  entity!(:person) { PersonResource.new(create(:person)) }

  entity!(:localpool) { create(:localpool)}

  entity(:user) { create(:person, :with_account, :with_self_role) }

  entity(:account) { Account::Base.where(person_id: user).first }

  # need to rereate on per test base as permissions are changing
  let(:pool) { Admin::LocalpoolResource.all(account).first }

  let(:subject) { Transactions::Admin::Localpool::AssignOwner.for(pool) }

  context 'authorize' do

    before do
      user.remove_role(Role::BUZZN_OPERATOR, localpool)
      user.add_role(Role::GROUP_MEMBER, localpool)
    end

    it 'fails' do
      expect { subject.call(person) }.to raise_error Buzzn::PermissionDenied
    end
  end

  context 'persist' do

    before do
      user.add_role(Role::BUZZN_OPERATOR, localpool)
      user.remove_role(Role::GROUP_MEMBER, localpool)
    end

    it 'succeeds' do
      result = subject.call(person)
      expect(result).to be_a Dry::Monads::Either::Right
      expect(result.value).to be_a PersonResource
      expect(result.value.object).to eq person.object
    end
  end
end
