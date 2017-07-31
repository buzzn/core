# coding: utf-8
describe Contract::BaseResource do

  entity(:admin) { Fabricate(:admin) }
  entity(:localpool) { Fabricate(:localpool) }

  entity(:metering_point_operator) { Fabricate(:metering_point_operator_contract,
                                            localpool: localpool) }
  entity(:localpool_processing) { Fabricate(:localpool_processing_contract,
                                            localpool: localpool) }
  entity(:localpool_power_taker) do
    register = Fabricate(:input_meter).input_register
    register.group = localpool
    Fabricate(:localpool_power_taker_contract, register: register)
  end
  entity(:power_taker) { Fabricate(:power_taker_contract_move_in) }
  entity(:power_giver) { Fabricate(:power_giver_contract) }

  let(:base_attributes) { ['id', 'type', 'updated_at',
                           'status',
                           'full_contract_number',
                           'customer_number',
                           'signing_user',
                           'signing_date',
                           'cancellation_date',
                           'end_date',
                           'updatable',
                           'deletable'] }
  let!(:all) { [metering_point_operator, localpool_processing, localpool_power_taker] }

  let(:resources) { Admin::LocalpoolResource.all(admin).retrieve(localpool.id).contracts }

  it 'retrieve' do
    all.each do |contract|
      attrs = resources.retrieve(contract.id).to_h
      expect(attrs.keys & base_attributes).to match_array base_attributes
    end
  end

  it 'retrieve all - ids + types' do
    expected = all.collect { |c| [c.class.to_s, c.id] }
    result = resources.collect do |r|
      [r.object.class.to_s, r.id]
    end
    expect(result).to match_array expected
  end

  [:customer, :customer_bank_account, :contractor,
   :contractor_bank_account].each do |name|
    it "nested #{name}" do
      all.each do |contract|
        obj = resources.retrieve(contract.id)
        expect(obj.send(name)).to be_an Buzzn::Resource::Base
        expect(obj.send("#{name}!")).to be_an Buzzn::Resource::Base
      end
    end
  end

  describe Contract::MeteringPointOperatorResource do

    it 'retrieve - ids + types' do
      result = resources.metering_point_operators.collect do |r|
        [r.type, r.id]
      end
      expect(result).to eq [['contract_metering_point_operator', metering_point_operator.id]]
    end

    it 'retrieve' do
      attributes = ['begin_date', 'metering_point_operator_name'] + base_attributes
      attrs = resources.retrieve(metering_point_operator.id).to_h
      expect(attrs['id']).to eq metering_point_operator.id
      expect(attrs['type']).to eq 'contract_metering_point_operator'
      expect(attrs.keys).to match_array attributes
    end
  end

  describe Contract::LocalpoolProcessingResource do

    it 'retrieve all - ids + types' do
      result = resources.localpool_processing.collect do |r|
        [r.type, r.id]
      end
      expect(result).to eq [['contract_localpool_processing', localpool_processing.id]]
    end

    it 'retrieve' do
      attributes = ['begin_date', 'first_master_uid', 'second_master_uid'] + base_attributes
      attrs = resources.retrieve(localpool_processing.id).to_h
      expect(attrs['id']).to eq localpool_processing.id
      expect(attrs['type']).to eq 'contract_localpool_processing'
      expect(attrs.keys).to match_array attributes
    end
  end

  describe Contract::LocalpoolPowerTakerResource do

    it 'retrieve - ids + types' do
      result = resources.localpool_power_takers.collect do |r|
        [r.object.class, r.id]
      end
      expect(result).to eq [[Contract::LocalpoolPowerTaker, localpool_power_taker.id]]
    end

    it 'retrieve' do
      attributes = ['begin_date',
                    'forecast_kwh_pa',
                    'renewable_energy_law_taxation',
                    'third_party_billing_number',
                    'third_party_renter_number',
                    'old_supplier_name',
                    'old_customer_number',
                    'old_account_number'] + base_attributes
      attrs = resources.retrieve(localpool_power_taker.id).to_h
      expect(attrs['id']).to eq localpool_power_taker.id
      expect(attrs['type']).to eq 'contract_localpool_power_taker'
      expect(attrs.keys).to match_array attributes
    end
  end
end
