# coding: utf-8
describe "Group Model" do

  entity!(:localpool) { Fabricate(:localpool) }
  entity!(:tribe) { Fabricate(:tribe) }

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

    it 'has organizations and persons' do
      second = Fabricate(:localpool) # has no contracts and thus no persons and orgas
      pools = Group::Localpool.where(id: [localpool, second])
      persons = localpool.contracts.collect { |c| c.customer }.uniq
      organizations = localpool.contracts.collect { |c| c.contractor }.uniq
      expect(pools.persons).to match_array persons
      expect(pools.organizations).to match_array organizations
      expect(localpool.persons).to match_array persons
      expect(localpool.organizations).to match_array organizations
    end

    it 'adds multiple addresses to localpool' do
      main_address = Fabricate(:address, city: 'Berlin', created_at: Time.now - 1.year)
      localpool.addresses << main_address
      secondary_address = Fabricate(:address, city: 'München')
      localpool.addresses << secondary_address

      expect(localpool.main_address.city).to eq main_address.city

      secondary_address.update_column(:created_at, Time.now - 2.years)

      expect(localpool.main_address.city).to eq secondary_address.city
    end

    it 'get a metering_point_operator_contract from localpool' do
      Fabricate(:metering_point_operator_contract, localpool: localpool)
      expect(localpool.metering_point_operator_contract).to be_a Contract::MeteringPointOperator
    end

    it 'get a localpool_processing_contract from localpool' do
      Fabricate(:localpool_processing_contract, localpool: localpool)
      expect(localpool.localpool_processing_contract).to be_a Contract::LocalpoolProcessing
    end

    it 'creates corrected ÜGZ registers' do
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
