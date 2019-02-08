
require_relative '../../../support/params_helper.rb'
require_relative 'shared_create'

describe Transactions::Admin::Contract::Localpool::CreateGapContracts, order: :defined do

  let(:localpool_start_date) { Date.new(2017, 02, 23) }
  let!(:localpool) { create(:group, :localpool, start_date: localpool_start_date) }
  let(:operator) { create(:account, :buzzn_operator) }
  let!(:localpoolr) { Admin::LocalpoolResource.all(operator).retrieve(localpool.id) }

  let(:resource) do
    localpool.save
    localpoolr.localpool_gap_contracts
  end

  5.times do |i|
    let!("meter_consumption_#{i+1}".to_sym) do
      create(:meter, :real, register_label: :grid_consumption, group: localpool)
    end

    let!("register_consumption_#{i+1}".to_sym) do
      send("meter_consumption_#{i+1}").registers.first
    end
  end

  let(:gap_person) do
    create(:person)
  end

  let(:request) do
    {
      begin_date: Date.new(2018,  1,  1),
      last_date:  Date.new(2018, 12, 31)
    }
  end

  context 'invalid state' do
    context 'without a gap contract customer' do

      let!(:lpc) do
        unless localpool.localpool_processing_contracts.any?
          create(:contract, :localpool_processing,
                 customer: localpool.owner,
                 contractor: Organization::Market.buzzn,
                 localpool: localpool)
        end
        localpool.reload
        localpool.localpool_processing_contracts.first
      end

      let(:result) do
        Transactions::Admin::Contract::Localpool::CreateGapContracts.new.(resource: resource, params: request, localpool: localpoolr)
      end

      it 'does not create' do
        expect {result}.to raise_error(Buzzn::ValidationError, '{:localpool=>{:gap_contract_customer=>["must be filled"]}}')
      end

    end

    context 'with a gap_contract customer' do

      before do
        localpool.gap_contract_customer = gap_person
        localpool.save
      end

      it_behaves_like 'without processing contract', Transactions::Admin::Contract::Localpool::CreateGapContracts.new do
        let(:params) { request }
        let(:lp) { localpoolr }
        let(:r) { resource }
      end

    end

  end

  context 'valid state' do

    before do
      localpoolr.object.gap_contract_customer = gap_person
      localpoolr.object.save
    end

    let!(:lpc) do
      unless localpool.localpool_processing_contracts.any?
        create(:contract, :localpool_processing,
               customer: localpoolr.object.owner,
               contractor: Organization::Market.buzzn,
               localpool: localpool)
      end
      localpoolr.object.reload
      localpoolr.object.localpool_processing_contracts.first
    end

    let(:result) do
      Transactions::Admin::Contract::Localpool::CreateGapContracts.new.(resource: resource, params: request, localpool: localpoolr)
    end

    before do
      localpool.gap_contract_customer = gap_person
      localpool.save
    end

    context 'no contracts' do
      it 'creates' do
        expect(result).to be_success
        res = result.value!
        expect(res).to be_a Array
        expect(res.count).to eql 5
        res.each do |element|
          expect(element).to be_a Contract::LocalpoolGapContractResource
        end
      end
    end

    context 'with contracts' do

      # register_consumption_1 has no contracts                       1 gap
      # register_consumption_2 has a contract in the middle           2 gaps
      # register_consumption_3 has a contract in the end              1 gap
      # register_consumption_4 has a contract in the beginning        1 gap
      # register_consumption_5 has a two contracts in the middle      3 gaps
      #                                                               ------
      #                                                               8 gaps

      let!(:contract_2_0) do
        create(:contract, :localpool_powertaker, localpool: localpool, register_meta: register_consumption_2.meta, begin_date: Date.new(2018, 4, 1), termination_date: Date.new(2018, 4, 1), end_date: Date.new(2018, 6, 1))
      end

      let!(:contract_3_0) do
        create(:contract, :localpool_powertaker, localpool: localpool, register_meta: register_consumption_3.meta, begin_date: Date.new(2018, 10, 1))
      end

      let!(:contract_4_0) do
        create(:contract, :localpool_powertaker, localpool: localpool, register_meta: register_consumption_4.meta, begin_date: Date.new(2017, 12, 1), termination_date: Date.new(2018, 3, 1), end_date: Date.new(2018, 4, 1))
      end

      let!(:contract_5_0) do
        create(:contract, :localpool_powertaker, localpool: localpool, register_meta: register_consumption_5.meta, begin_date: Date.new(2018, 4, 1), termination_date: Date.new(2018, 5, 1), end_date: Date.new(2018, 5, 2))
      end

      let!(:contract_5_1) do
        create(:contract, :localpool_powertaker, localpool: localpool, register_meta: register_consumption_5.meta, begin_date: Date.new(2018, 9, 1), termination_date: Date.new(2018, 10, 1), end_date: Date.new(2018, 10, 2))
      end

      it 'creates' do
        expect(result).to be_success
        res = result.value!
        expect(res).to be_a Array
        expect(res.count).to eql 8
        res.each do |element|
          expect(element).to be_a Contract::LocalpoolGapContractResource
        end
        5.times do |i|
          send("register_consumption_#{i+1}").meta.reload
        end

        # register_consumption_1

        expect(register_consumption_1.meta.contracts.count).to eql 1
        # should be a gap contract
        contract1 = register_consumption_1.meta.contracts.first
        expect(contract1).to be_a Contract::LocalpoolGap
        expect(contract1.begin_date).to eql Date.new(2018, 1, 1)
        expect(contract1.end_date).to   eql Date.new(2019, 1, 1)

        # register_consumption_2
        expect(register_consumption_2.meta.contracts.count).to eql 3
        register_consumption_2.meta.contracts.order(:begin_date).to_a.each_with_index do |contract, idx| 
          case idx
          when 0
            expect(contract).to be_a Contract::LocalpoolGap
            expect(contract.begin_date).to eql Date.new(2018, 1, 1)
            expect(contract.end_date).to   eql Date.new(2018, 4, 1)
          when 1
            expect(contract).to be_a Contract::LocalpoolPowerTaker
            expect(contract.begin_date).to eql Date.new(2018, 4, 1)
            expect(contract.end_date).to   eql Date.new(2018, 6, 1)
          when 2
            expect(contract).to be_a Contract::LocalpoolGap
            expect(contract.begin_date).to eql Date.new(2018, 6, 1)
            expect(contract.end_date).to   eql Date.new(2019, 1, 1)
          end
        end

        # register_consumption_3
        expect(register_consumption_3.meta.contracts.count).to eql 2
        register_consumption_3.meta.contracts.order(:begin_date).to_a.each_with_index do |contract, idx| 
          case idx
          when 0
            expect(contract).to be_a Contract::LocalpoolGap
            expect(contract.begin_date).to eql Date.new(2018, 1, 1)
            expect(contract.end_date).to   eql Date.new(2018, 10, 1)
          when 1
            expect(contract).to be_a Contract::LocalpoolPowerTaker
            expect(contract.begin_date).to eql Date.new(2018, 10, 1)
            expect(contract.end_date).to   eql nil
          end
        end

        # register_consumption_4
        expect(register_consumption_4.meta.contracts.count).to eql 2
        register_consumption_4.meta.contracts.order(:begin_date).to_a.each_with_index do |contract, idx| 
          case idx
          when 0
            expect(contract).to be_a Contract::LocalpoolPowerTaker
            expect(contract.begin_date).to eql Date.new(2017, 12, 1)
            expect(contract.end_date).to   eql Date.new(2018, 4, 1)
          when 1
            expect(contract).to be_a Contract::LocalpoolGap
            expect(contract.begin_date).to eql Date.new(2018, 4, 1)
            expect(contract.end_date).to   eql Date.new(2019, 1, 1)
          end
        end

        # register_consumption_5
        expect(register_consumption_5.meta.contracts.count).to eql 5
        register_consumption_5.meta.contracts.order(:begin_date).to_a.each_with_index do |contract, idx| 
          case idx
          when 0
            expect(contract).to be_a Contract::LocalpoolGap
            expect(contract.begin_date).to eql Date.new(2018, 1, 1)
            expect(contract.end_date).to   eql Date.new(2018, 4, 1)
          when 1
            expect(contract).to be_a Contract::LocalpoolPowerTaker
            expect(contract.begin_date).to eql Date.new(2018, 4, 1)
            expect(contract.end_date).to   eql Date.new(2018, 5, 2)
          when 2
            expect(contract).to be_a Contract::LocalpoolGap
            expect(contract.begin_date).to eql Date.new(2018, 5, 2)
            expect(contract.end_date).to   eql Date.new(2018, 9, 1)
          when 3
            expect(contract).to be_a Contract::LocalpoolPowerTaker
            expect(contract.begin_date).to eql Date.new(2018, 9, 1)
            expect(contract.end_date).to   eql Date.new(2018, 10, 2)
          when 4
            expect(contract).to be_a Contract::LocalpoolGap
            expect(contract.begin_date).to eql Date.new(2018, 10, 2)
            expect(contract.end_date).to   eql Date.new(2019,  1, 1)
          end
        end

      end

    end

    context 'valid state with readings' do

      let!(:install_reading_1) do
        create(:reading, :setup, raw_value: 0, register: register_consumption_1, date: Date.new(2018, 4, 1))
      end

      let!(:install_reading_2) do
        create(:reading, :setup, raw_value: 0, register: register_consumption_2, date: Date.new(2018, 4, 1))
      end

      let!(:remove_reading_2) do
        create(:reading, :remove, raw_value: 137, register: register_consumption_2, date: Date.new(2018, 8, 1))
      end

      it 'creates' do
        expect(result).to be_success
        res = result.value!
        expect(res).to be_a Array
        expect(res.count).to eql 5
        res.each do |element|
          expect(element).to be_a Contract::LocalpoolGapContractResource
        end

        5.times do |i|
          send("register_consumption_#{i+1}").meta.reload
        end
        # should be a gap contract
        contract1 = register_consumption_1.meta.contracts.first
        expect(contract1.begin_date).to eql Date.new(2018, 4, 1)
        expect(contract1.end_date).to   eql Date.new(2019, 1, 1)

        # should be a gap contract
        contract2 = register_consumption_2.meta.contracts.first
        expect(contract2.begin_date).to eql Date.new(2018, 4, 1)
        expect(contract2.end_date).to   eql Date.new(2018, 8, 1)

      end

    end

  end

end
