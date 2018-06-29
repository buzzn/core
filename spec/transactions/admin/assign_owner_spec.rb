require 'buzzn/transactions/admin/localpool/assign_owner'

describe Transactions::Admin::Localpool::OwnerBase do

  let!(:localpool)         { create(:group, :localpool) }
  let(:person)             { create(:person) }
  let(:person_resource)    { PersonResource.new(person) }

  let(:account)            { Account::Base.where(person_id: user).first }
  let(:localpool_resource) { Admin::LocalpoolResource.all(account).first }
  let(:transaction)        { Transactions::Admin::Localpool::AssignOwner.new }

  context 'authorize' do

    let(:user) { create(:person, :with_account, :with_self_role, roles: { Role::GROUP_MEMBER => localpool }) }

    it 'fails' do
      expect { transaction.call(resource: localpool_resource, new_owner: person_resource) }.to raise_error Buzzn::PermissionDenied
    end
  end

  context 'persist' do

    let(:user) { create(:person, :with_account, :with_self_role, roles: { Role::BUZZN_OPERATOR => nil }) }

    it 'succeeds' do
      result = transaction.call(resource: localpool_resource, new_owner: person_resource)
      expect(result).to be_success
      expect(result.value!).to be_a PersonResource
      expect(result.value!.object).to eq(person)
    end
  end
end
