require 'buzzn/transactions/admin/localpool/owner_base'

describe Transactions::Admin::Localpool::OwnerBase do

  entity(:user) { create(:person, :with_account, roles: [Role::BUZZN_OPERATOR]) }

  entity(:account) { Account::Base.where(person_id: user).first }

#  entity!(:localpool) { Fabricate(:localpool) }

  entity!(:pools) do
    create(:localpool)
    Admin::LocalpoolResource.all(account)
  end

  entity!(:pool) { pools.first }

  entity!(:person) { PersonResource.new(create(:person)) }

  entity!(:person2) { PersonResource.new(create(:person)) }

  entity!(:organization) do
    # use BUZZN_OPERATOR role to have access to child objects
    OrganizationResource.new(create(:organization, :other, contact: create(:person)), current_roles: [Role::BUZZN_OPERATOR], permissions: pool.permissions.owner)
  end

  entity!(:organization2) do
    # use BUZZN_OPERATOR role to have access to child objects
    OrganizationResource.new(create(:organization, :other, contact: create(:person)), current_roles: [Role::BUZZN_OPERATOR], permissions: pool.permissions.owner)
  end

  let(:subject) { Transactions::Admin::Localpool::OwnerBase.for }

  context Person do

    it 'unassign' do
      subject.assign_owner(pool, nil)

      expect(organization.contact.object.has_role?(Role::GROUP_OWNER, pool.object)).to eq false
      expect(organization.contact.object.roles.size).to eq 0
      expect(pool.owner).to be_nil
    end

    it 'assign' do
      pool.object.update(owner: nil)
      subject.assign_owner(pool, person)

      expect(person.object.has_role?(Role::GROUP_OWNER, pool.object)).to eq true
      expect(person.object.roles.size).to eq 1
      expect(pool.owner.object).to eq person.object
    end

    context 'change' do

      it Person do
        subject.assign_owner(pool, person2)

        expect(person.object.has_role?(Role::GROUP_OWNER, pool.object)).to eq false
        expect(person.object.roles.size).to eq 0
        expect(person2.object.has_role?(Role::GROUP_OWNER, pool.object)).to eq true
        expect(person2.object.roles.size).to eq 1
        expect(organization.contact.object.has_role?(Role::GROUP_OWNER, pool.object)).to eq false
        expect(organization.contact.object.roles.size).to eq 0
      end

      it Organization do
        subject.assign_owner(pool, organization)

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
      subject.assign_owner(pool, nil)

      expect(organization.contact.object.has_role?(Role::GROUP_OWNER, pool.object)).to eq false
      expect(organization.contact.object.roles.size).to eq 0
      expect(pool.owner).to be_nil
    end

    it 'assign' do
      subject.assign_owner(pool, organization)

      expect(organization.contact.object.has_role?(Role::GROUP_OWNER, pool.object)).to eq true
      expect(organization.contact.object.roles.size).to eq 1
      expect(pool.owner.object).to eq organization.object
    end

    context 'change' do

      it Person do
        subject.assign_owner(pool, person)

        expect(person.object.has_role?(Role::GROUP_OWNER, pool.object)).to eq true
        expect(person.object.roles.size).to eq 1
        expect(organization.contact.object.has_role?(Role::GROUP_OWNER, pool.object)).to eq false
        expect(organization.contact.object.roles.size).to eq 0
        expect(organization2.contact.object.has_role?(Role::GROUP_OWNER, pool.object)).to eq false
        expect(organization2.contact.object.roles.size).to eq 0
        expect(pool.owner.object).to eq person.object
      end

      it Organization do
        subject.assign_owner(pool, organization2)

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
