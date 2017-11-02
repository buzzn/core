require 'buzzn/schemas/invariants/group/localpool'

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

    describe 'invariants on' do
      let(:schema) { Schemas::Invariants::Group::Localpool }
      let(:localpool) { Fabricate.build(:localpool, owner: nil) }
      let(:validator) { Buzzn::Schemas::ActiveRecordValidator.new(localpool) }
      context 'grid_consumption_register' do
        entity(:register) { Fabricate(:input_meter).input_register }
        before { localpool.update(grid_consumption_register: register) }
        context 'no meter.group' do
          before { register.meter.group = nil }
          context 'meter.register.group' do
            before { register.group = localpool }
            it 'is broken' do
              expect(validator.validate(schema)[:grid_consumption_register]).not_to be_nil
            end
          end
          context 'no meter.register.group' do
            before { register.group = nil }
            it 'is broken' do
              expect(validator.validate(schema)[:grid_consumption_register]).not_to be_nil
            end
          end
        end

        context 'right meter.group' do
          before { register.meter.group = localpool }
          context 'no meter.register.group' do
            before { register.group = nil }
            it 'is valid' do
              expect(validator.validate(schema)[:grid_consumption_register]).to be_nil
            end
          end
          context 'meter.register.group' do
            before { register.group = localpool }
            it 'is broken' do
              expect(validator.validate(schema)[:grid_consumption_register]).not_to be_nil
            end
          end
        end

        context 'wrong meter.group' do
          entity(:other) { Fabricate(:localpool, owner: nil) }
          before { register.meter.group = other }
          context 'no meter.register.group' do
            before { register.group = nil }
            it 'is broken' do
              expect(validator.validate(schema)[:grid_consumption_register]).not_to be_nil
            end
          end
          context 'meter.register.group' do
            before { register.group = localpool }
            it 'is broken' do
              expect(validator.validate(schema)[:grid_consumption_register]).not_to be_nil
            end
          end
        end
      end

      context 'grid_feeding_register' do
        entity(:register) { Fabricate(:output_meter).output_register }
        before { localpool.update(grid_feeding_register: register) }
        context 'no meter.group' do
          before { register.meter.group = nil }
          context 'meter.register.group' do
            before { register.group = localpool }
            it 'is broken' do
              expect(validator.validate(schema)[:grid_feeding_register]).not_to be_nil
            end
          end
          context 'no meter.register.group' do
            before { register.group = nil }
            it 'is broken' do
              expect(validator.validate(schema)[:grid_feeding_register]).not_to be_nil
            end
          end
        end

        context 'right meter.group' do
          before { register.meter.group = localpool }
          context 'no meter.register.group' do
            before { register.group = nil }
            it 'is valid' do
              expect(validator.validate(schema)[:grid_feeding_register]).to be_nil
            end
          end
          context 'meter.register.group' do
            before { register.group = localpool }
            it 'is broken' do
              expect(validator.validate(schema)[:grid_feeding_register]).not_to be_nil
            end
          end
        end

        context 'wrong meter.group' do
          entity(:other) { Fabricate(:localpool, owner: nil) }
          before { register.meter.group = other }
          context 'no meter.register.group' do
            before { register.group = nil }
            it 'is broken' do
              expect(validator.validate(schema)[:grid_feeding_register]).not_to be_nil
            end
          end
          context 'meter.register.group' do
            before { register.group = localpool }
            it 'is broken' do
              expect(validator.validate(schema)[:grid_feeding_register]).not_to be_nil
            end
          end
        end
      end
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
end

# the below test throws an error which rolls back the nested transaction, i.e.
# run it without nested transactions
describe Group::Localpool, :skip_nested do

  let(:person) {  Fabricate(:person) }
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
