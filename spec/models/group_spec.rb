describe Group::Base do

  entity!(:localpool) { Fabricate(:localpool) }
  entity!(:tribe)     { Fabricate(:tribe) }

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

  it 'calculates scores of all groups via sidekiq' do
    expect {
      Group::Base.calculate_scores
    }.to change(CalculateGroupScoresWorker.jobs, :size).by(1)
  end

  describe Group::Localpool do

    let(:buzzn) { Organization.buzzn }

    it 'has organizations and persons' do
      skip "Clarify with Christian how this should behave. Right now none of the localpools have persons or orgs."
      localpool_without_contracts = Fabricate(:localpool)
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
      create(:contract, :metering_point_operator, :with_tariff, :with_payment, localpool: localpool, contractor: buzzn)
      expect(localpool.metering_point_operator_contract).to be_a Contract::MeteringPointOperator
    end

    it 'get a localpool_processing_contract from localpool' do
      create(:contract, :localpool_processing, :with_tariff, :with_payment, localpool: localpool, contractor: buzzn)
      expect(localpool.localpool_processing_contract).to be_a Contract::LocalpoolProcessing
    end

    xit 'creates corrected ÜGZ registers' do
      expect(localpool.registers.grid_consumption_corrected.size).to eq 1
      expect(localpool.registers.grid_feeding_corrected.size).to eq 1
    end

    describe 'assigning owner' do
      let(:localpool) { build(:localpool, owner: nil) }
      context 'when new owner is an organization' do
        let(:new_owner) { create(:organization) }
        before { expect(localpool.owner).to be_nil } # assert precondition ...
        it 'is a assigned correctly' do
          localpool.owner = new_owner
          expect(localpool.owner).to eq(new_owner)
          localpool.save && localpool.reload
          expect(localpool.owner).to eq(new_owner)
        end
      end
      context 'when new owner is a person' do
        let(:new_owner) { create(:person) }
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
end

# the below test throws an error which rolls back the nested transaction, i.e.
# run it without nested transactions
describe Group::Localpool, :skip_nested do

  let(:person) {  Fabricate(:person) }
  let(:organization) { Fabricate(:other_organization) }
  let(:localpool) { Fabricate(:localpool, person: person) }

  after do
    localpool.delete
    person.delete
    organization.delete
    Register::Base.delete_all
    Meter::Base.delete_all
  end

  it 'has one owner' do
    localpool.organization = organization
    expect { localpool.save }.to raise_error ActiveRecord::StatementInvalid
    localpool.person = nil
    expect { localpool.save }.not_to raise_error
  end

end
