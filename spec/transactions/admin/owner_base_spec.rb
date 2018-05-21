require 'buzzn/transactions/admin/localpool/owner_base'

describe Transactions::Admin::Localpool::OwnerBase do

  entity(:user) { create(:person, :with_account, roles: [Role::BUZZN_OPERATOR]) }

  entity(:account) { Account::Base.where(person_id: user).first }

  entity!(:pools) do
    create(:localpool)
    Admin::LocalpoolResource.all(account)
  end

  entity!(:pool) { pools.first }

  entity!(:person) { PersonResource.new(create(:person), pool.security_context.owner) }

  entity!(:person2) { PersonResource.new(create(:person), pool.security_context.owner) }

  entity!(:organization) do
    OrganizationResource.new(create(:organization, :other, contact: create(:person)), pool.security_context.owner)
  end

  entity!(:organization2) do
    OrganizationResource.new(create(:organization, :other, contact: create(:person)), pool.security_context.owner)
  end

  let(:subject) { Transactions::Admin::Localpool::OwnerBase.new }

  before { person.roles.delete_all }

  context Person do

    it 'unassign' do
      subject.assign_owner(new_owner: nil, resource: pool)

      expect(organization.contact.object.has_role?(Role::GROUP_OWNER, pool.object)).to eq false
      expect(organization.contact.object.roles.size).to eq 0
      expect(pool.owner).to be_nil
    end

    it 'assign' do
      pool.object.update(owner: nil)
      subject.assign_owner(new_owner: person, resource: pool)

      expect(person.object.has_role?(Role::GROUP_OWNER, pool.object)).to eq true
      expect(person.object.roles.size).to eq 1
      expect(pool.owner.object).to eq person.object
    end

    context 'change' do

      it Person do
        subject.assign_owner(new_owner: person2, resource: pool)

        expect(person.object.has_role?(Role::GROUP_OWNER, pool.object)).to eq false
        expect(person.object.roles.size).to eq 0
        expect(person2.object.has_role?(Role::GROUP_OWNER, pool.object)).to eq true
        expect(person2.object.roles.size).to eq 1
        expect(organization.contact.object.has_role?(Role::GROUP_OWNER, pool.object)).to eq false
        expect(organization.contact.object.roles.size).to eq 0
      end

      it Organization do
        subject.assign_owner(new_owner: organization, resource: pool)

        expect(person.object.has_role?(Role::GROUP_OWNER, pool.object)).to eq false
        expect(person.object.roles.size).to eq 0
        expect(person2.object.has_role?(Role::GROUP_OWNER, pool.object)).to eq false
        expect(person2.object.roles.size).to eq 0
        expect(organization.contact.object.has_role?(Role::GROUP_OWNER, pool.object)).to eq true
        expect(organization.contact.object.roles.size).to eq 1
      end
    end
  end

  context Organization do

    it 'unassign' do
      subject.assign_owner(new_owner: nil, resource: pool)

      expect(organization.contact.object.has_role?(Role::GROUP_OWNER, pool.object)).to eq false
      expect(organization.contact.object.roles.size).to eq 0
      expect(pool.owner).to be_nil
    end

    it 'assign' do
      subject.assign_owner(new_owner: organization, resource: pool)

      expect(organization.contact.object.has_role?(Role::GROUP_OWNER, pool.object)).to eq true
      expect(organization.contact.object.roles.size).to eq 1
      expect(pool.owner.object).to eq organization.object
    end

    context 'change' do

      it Person do
        subject.assign_owner(new_owner: person, resource: pool)

        expect(person.object.has_role?(Role::GROUP_OWNER, pool.object)).to eq true
        expect(person.object.roles.size).to eq 1
        expect(organization.contact.object.has_role?(Role::GROUP_OWNER, pool.object)).to eq false
        expect(organization.contact.object.roles.size).to eq 0
        expect(organization2.contact.object.has_role?(Role::GROUP_OWNER, pool.object)).to eq false
        expect(organization2.contact.object.roles.size).to eq 0
        expect(pool.owner.object).to eq person.object
      end

      it Organization do
        subject.assign_owner(new_owner: organization2, resource: pool)

        expect(person.object.has_role?(Role::GROUP_OWNER, pool.object)).to eq false
        expect(person.object.roles.size).to eq 0
        expect(person2.object.has_role?(Role::GROUP_OWNER, pool.object)).to eq false
        expect(person2.object.roles.size).to eq 0
        expect(organization.contact.object.has_role?(Role::GROUP_OWNER, pool.object)).to eq false
        expect(organization.contact.object.roles.size).to eq 0
        expect(organization2.contact.object.has_role?(Role::GROUP_OWNER, pool.object)).to eq true
        expect(organization2.contact.object.roles.size).to eq 1
        expect(pool.owner.object).to eq organization2.object
      end
    end
  end
end
