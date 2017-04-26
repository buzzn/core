# coding: utf-8
describe Contract::BaseResource do

  let(:user) { entities[:admin] ||= Fabricate(:admin) }
  let(:localpool) { entities[:localpool] ||= Fabricate(:localpool) }

  let(:metering_point_operator) { entities[:metering_point_operator] ||= Fabricate(:metering_point_operator_contract,
                                            localpool: localpool) }
  let(:localpool_processing) { entities[:localpool_processing] ||= Fabricate(:localpool_processing_contract,
                                         localpool: localpool) }
  let(:localpool_power_taker) do
    entities[:localpool_power_taker] ||=
      begin 
        register = Fabricate(:input_meter).input_register
        register.group = localpool
        Fabricate(:localpool_power_taker_contract, register: register)
      end
  end
  let(:power_taker) { entities[:power_taker] ||= Fabricate(:power_taker_contract_move_in) }
  let(:power_giver) { entities[:power_giver] ||= Fabricate(:power_giver_contract) }

  let(:base_attributes) { [:status,
                           :full_contract_number,
                           :customer_number,
                           :signing_date,
                           :cancellation_date,
                           :end_date,
                           :tariffs,
                           :payments,
                           :contractor,
                           :customer,
                           :signing_user,
                           :customer_bank_account,
                           :contractor_bank_account,
                           :updatable,
                           :deletable] }
  let!(:all) { [metering_point_operator, localpool_processing, localpool_power_taker, power_taker, power_giver] }

  #describe Contract::BaseResource do

    it 'retrieve' do
      all.each do |contract|
        json = Contract::BaseResource.retrieve(user, contract.id).to_h
        expect(json.keys & base_attributes).to match_array base_attributes
      end
    end

    it 'retrieve all - ids + types' do
      expected = all.collect { |c| [c.class, c.id] }
      result = Contract::BaseResource.all(user).collect do |r|
        [r.type.constantize, r.id]
      end
      expect(result).to match_array expected
    end

    it 'nested entities' do
      all.each do |contract|
        obj = Contract::BaseResource.retrieve(user, contract.id)
        [:customer!, :contractor!].each do |name|
          # TODO all the other nested as well: :signing_user!, :bank_account!
          #      and the ones without shebang
          expect(obj.send(name)).to be_an ActiveModel::Serializer
        end
      end
    end
  #end

  describe Contract::MeteringPointOperatorResource do

    it 'retrieve - ids + types' do
      result = Contract::MeteringPointOperatorResource.all(user).collect do |r|
        [r.type.constantize, r.id]
      end
      expect(result).to eq [[Contract::MeteringPointOperator, metering_point_operator.id]]
    end

    it "retrieve - id + type" do
      [Contract::BaseResource, Contract::MeteringPointOperatorResource].each do |type|
        json = type.retrieve(user, metering_point_operator.id).to_h
        expect(json[:id]).to eq metering_point_operator.id
        expect(json[:type]).to eq 'contract_metering_point_operator'
      end
      all.reject{ |c| c.is_a? Contract::MeteringPointOperator }
        .each do |contract|
        expect{Contract::MeteringPointOperatorResource.retrieve(user, contract.id)}.to raise_error Buzzn::RecordNotFound
      end
    end

    it 'retrieve' do
      attributes = [:begin_date, :metering_point_operator_name]
      json = Contract::BaseResource.retrieve(user, metering_point_operator.id).to_h
      expect(json.keys & attributes).to match_array attributes
      expect(json.keys.size).to eq (attributes.size + base_attributes.size + 2)
    end
  end

  describe Contract::LocalpoolProcessingResource do

    it 'retrieve all - ids + types' do
      result = Contract::LocalpoolProcessingResource.all(user).collect do |r|
        [r.type.constantize, r.id]
      end
      expect(result).to eq [[Contract::LocalpoolProcessing, localpool_processing.id]]
    end

    it "retrieve - id + type" do
      [Contract::BaseResource, Contract::LocalpoolProcessingResource].each do |type|
        json = type.retrieve(user, localpool_processing.id).to_h
        expect(json[:id]).to eq localpool_processing.id
        expect(json[:type]).to eq 'contract_localpool_processing'
      end
      all.reject{ |c| c.is_a? Contract::LocalpoolProcessing }
        .each do |contract|
        expect{Contract::LocalpoolProcessingResource.retrieve(user, contract.id)}.to raise_error Buzzn::RecordNotFound
      end
    end

    it 'retrieve' do
      attributes = [:begin_date, :first_master_uid, :second_master_uid]
      json = Contract::BaseResource.retrieve(user, localpool_processing.id).to_h
      expect(json.keys & attributes).to match_array attributes
      expect(json.keys.size).to eq (attributes.size + base_attributes.size + 2)
    end
  end

  describe Contract::LocalpoolPowerTakerResource do

    it 'retrieve - ids + types' do
      result = Contract::LocalpoolPowerTakerResource.all(user).collect do |r|
        [r.type.constantize, r.id]
      end
      expect(result).to eq [[Contract::LocalpoolPowerTaker, localpool_power_taker.id]]
    end

    it "retrieve - id + type" do
      [Contract::BaseResource, Contract::LocalpoolPowerTakerResource].each do |type|
        json = type.retrieve(user, localpool_power_taker.id).to_h
        expect(json[:id]).to eq localpool_power_taker.id
        expect(json[:type]).to eq 'contract_localpool_power_taker'
      end
      all.reject{ |c| c.is_a? Contract::LocalpoolPowerTaker }
        .each do |contract|
        expect{Contract::LocalpoolPowerTakerResource.retrieve(user, contract.id)}.to raise_error Buzzn::RecordNotFound
      end
    end

    it 'retrieve' do
      attributes = []
      json = Contract::BaseResource.retrieve(user, localpool_power_taker.id).to_h
      expect(json.keys & attributes).to match_array attributes
      expect(json.keys.size).to eq (attributes.size + base_attributes.size + 2)
    end
  end

  describe Contract::PowerTakerResource do

    it 'retrieve all - ids + types' do
      result = Contract::PowerTakerResource.all(user).collect do |r|
        [r.type.constantize, r.id]
      end
      expect(result).to eq [[Contract::PowerTaker, power_taker.id]]
    end

    it "retrieve - id + type" do
      [Contract::BaseResource, Contract::PowerTakerResource].each do |type|
        json = type.retrieve(user, power_taker.id).to_h
        expect(json[:id]).to eq power_taker.id
        expect(json[:type]).to eq 'contract_power_taker'
      end
      all.reject{ |c| c.is_a? Contract::PowerTaker }
        .each do |contract|
        expect{Contract::PowerTakerResource.retrieve(user, contract.id)}.to raise_error Buzzn::RecordNotFound
      end
    end

    it 'retrieve' do
      attributes = []
      json = Contract::BaseResource.retrieve(user, power_taker.id).to_h
      expect(json.keys & attributes).to match_array attributes
      expect(json.keys.size).to eq (attributes.size + base_attributes.size + 2)
    end
  end

  describe Contract::PowerGiverResource do

    it 'retrieve all - ids + types' do
      result = Contract::PowerGiverResource.all(user).collect do |r|
        [r.type.constantize, r.id]
      end
      expect(result).to eq [[Contract::PowerGiver, power_giver.id]]
    end

    it "retrieve - id + type" do
      [Contract::BaseResource, Contract::PowerGiverResource].each do |type|
        json = type.retrieve(user, power_giver.id).to_h
        expect(json[:id]).to eq power_giver.id
        expect(json[:type]).to eq 'contract_power_giver'
      end
      all.reject{ |c| c.is_a? Contract::PowerGiver }
        .each do |contract|
        expect{Contract::PowerGiverResource.retrieve(user, contract.id)}.to raise_error Buzzn::RecordNotFound
      end
    end

    it 'retrieve' do
      attributes = []
      json = Contract::BaseResource.retrieve(user, power_giver.id).to_h
      expect(json.keys & attributes).to match_array attributes
      expect(json.keys.size).to eq (attributes.size + base_attributes.size + 2)
    end
  end
end
