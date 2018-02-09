require 'buzzn/schemas/invariants/group/localpool'

describe Group::Base do

  entity!(:localpool) { create(:localpool) }
  entity!(:tribe)     { create(:localpool) }

  it 'filters group' do
    group = [tribe, localpool].sample

    [group.name, group.description].each do |val|
      [val, val.upcase, val.downcase, val[0..4], val[-4..-1]].each do |value|
        groups = Group::Base.filter(value)
        expect(groups).to include group
      end
    end
  end

  it 'can not find anything' do
    groups = Group::Base.filter('Der Clown ist müde und geht nach Hause.')
    expect(groups.size).to eq 0
  end

  it 'filters group with no params' do
    groups = Group::Base.filter(nil)
    expect(groups.size).to eq Group::Base.count
  end

  describe Group::Localpool do

    entity(:buzzn) { Organization.buzzn }

    entity!(:localpool_with_contracts) do
      create(:contract, :metering_point_operator, :with_tariff, :with_payment, localpool: localpool, contractor: buzzn)
      create(:contract, :localpool_processing, :with_tariff, :with_payment, localpool: localpool, contractor: buzzn)
      localpool
    end

    it 'has organizations and persons' do
      localpool_without_contracts = create(:localpool)
      both_localpools = Group::Localpool.where(id: [localpool, localpool_without_contracts])
      persons = localpool.contracts.collect { |c| c.customer }.uniq
      expect(persons.size).to be > 0
      organizations = localpool.contracts.collect { |c| c.contractor }.uniq
      expect(both_localpools.persons).to match_array persons
      expect(both_localpools.organizations).to match_array organizations
      expect(localpool.persons).to match_array persons
      expect(localpool.organizations).to match_array organizations
    end

    it 'get a metering_point_operator_contract from localpool' do
      expect(localpool.metering_point_operator_contract).to be_a Contract::MeteringPointOperator
    end

    it 'get a localpool_processing_contract from localpool' do
      expect(localpool.localpool_processing_contract).to be_a Contract::LocalpoolProcessing
    end

    describe 'assigning owner' do
      let(:localpool) { Fabricate.build(:localpool, owner: nil) }
      context 'when new owner is an organization' do
        let(:new_owner) { Fabricate(:other_organization) }
        before { expect(localpool.owner).to be_nil } # assert precondition ...
        it 'is a assigned correctly' do
          localpool.owner = new_owner
          expect(localpool.owner).to eq(new_owner)
          localpool.save && localpool.reload
          expect(localpool.owner).to eq(new_owner)
        end
      end
      context 'when new owner is a person' do
        let(:new_owner) { Fabricate(:person) }
        it 'is a assigned correctly' do
          localpool.owner = new_owner
          expect(localpool.owner).to eq(new_owner)
          localpool.save && localpool.reload
          expect(localpool.owner).to eq(new_owner)
        end
      end
      context 'when new owner is neither person nor organization' do
        it 'raises an exception' do
          expect { localpool.owner = OpenStruct.new }.to raise_error(RuntimeError, /Can't assign/)
        end
      end
    end
  end

  context 'mentors' do
    let(:group) { create(:localpool) }

    context 'Group has no energy mentor' do
      it 'returns an empty array' do
        expect(group.mentors).to eq([])
      end
    end

    context 'Group has one energy mentor' do
      let(:person) { create(:person) }
      before { person.add_role(Role::GROUP_ENERGY_MENTOR, group) }

      it 'returns the person' do
        expect(group.mentors).to eq([person])
      end
    end

    context 'Group has two energy mentors' do
      let(:persons) { create_list(:person, 2) }
      before { persons.each { |person| person.add_role(Role::GROUP_ENERGY_MENTOR, group) } }

      it 'returns both persons' do
        expect(group.mentors).to match_array(persons)
      end
    end
  end
end

# the below test throws an error which rolls back the nested transaction, i.e.
# run it without nested transactions
describe Group::Localpool, :skip_nested do

  let(:person) { Fabricate(:person) }
  let(:organization) { Fabricate(:other_organization) }
  let(:localpool) { Fabricate(:localpool, owner_person: person) }

  after do
    localpool.delete
    person.delete
    organization.delete
    Register::Base.delete_all
    Meter::Base.delete_all
  end

  it 'has one owner' do
    localpool.owner_organization = organization
    expect { localpool.save }.to raise_error ActiveRecord::StatementInvalid
    localpool.owner_person = nil
    expect { localpool.save }.not_to raise_error
  end

end
