require 'buzzn/transactions/admin/billing/create'
require_relative '../../../support/discovergy_helper'

describe Transactions::Admin::Billing::Create do
  before(:each) do
    Import.global('services.redis_cache').flushall
  end

  let!(:localpool) { create(:group, :localpool) }
  let(:operator) { create(:account, :buzzn_operator) }
  let!(:localpoolr) { Admin::LocalpoolResource.all(operator).retrieve(localpool.id) }

  let(:lpc) do
    create(:contract, :localpool_processing,
           customer: localpool.owner,
           contractor: Organization::Market.buzzn,
           localpool: localpool)
  end

  let(:person) do
    create(:person, :with_bank_account)
  end

  let(:meter) do
    create(:meter, :real, :connected_to_discovergy, :one_way, group: localpool)
  end

  # tariff configuration
  #
  #       | contract |
  #         |billing|
  #  | tariff 1 | tariff 2....

  let(:tariff1) do
    create(:tariff, group: localpool, begin_date: contract.begin_date - 90)
  end

  let(:tariff2) do
    create(:tariff, group: localpool, begin_date: contract.begin_date + 32)
  end

  let(:contract) do
    create(:contract, :localpool_powertaker,
           customer: person,
           register_meta: meter.registers.first.meta,
           contractor: Organization::Market.buzzn,
           localpool: localpool)
  end

  let!(:billingsr) do
    localpoolr.contracts.retrieve(contract.id).billings
  end

  let(:begin_date) { contract.begin_date + 10 }
  let(:last_date)   { begin_date + 90 }
  let(:end_date)   { begin_date + 90 + 1 }

  let(:params) do
    {
      :begin_date => begin_date,
      :last_date => last_date,
    }
  end

  # inject some fake readings
  entity(:single_reading) do
    Import.global('services.datasource.discovergy.single_reading')
  end

  let(:result) do
    Transactions::Admin::Billing::Create.new.(resource: billingsr,
                                              params: params,
                                              contract: contract,
                                              billing_cycle: nil)
  end

  let!(:install_reading) do
    create(:reading, :setup, raw_value: 0, register: meter.registers.first, date: begin_date - 2.day)
  end

  context 'with a single tariff' do

    before do
      contract.tariffs << tariff1
      contract.tariffs.reload
    end

    context 'without a connected meter' do

      context 'without a billing item' do
        it 'creates' do
          res = result
          expect(res).to be_success
          value = res.value!
          expect(value).to be_a Admin::BillingResource
          object = value.object
          expect(object.items.count).to eql 1
          expect(object.items.first.begin_reading).to be_nil
          expect(object.items.first.end_reading).to be_nil
        end
      end

      context 'with a billing item in the middle' do
        let(:another_billing) { create(:billing, contract: contract) }
        let!(:another_billing_item) { create(:billing_item, begin_date: begin_date + 3, end_date: begin_date + 5, register: meter.registers.first, billing: another_billing) }

        it 'creates' do
          contract.register_meta.reload

          res = result
          expect(res).to be_success
          value = res.value!
          expect(value).to be_a Admin::BillingResource
          object = value.object
          expect(object.items.count).to eql 2
          item0 = object.items[0]
          item1 = another_billing_item
          item2 = object.items[1]
          expect(item0.begin_date).to eql begin_date
          expect(item0.end_date).to eql item1.begin_date
          expect(item1.end_date).to eql item2.begin_date
          expect(item2.end_date).to eql end_date
        end
      end

      context 'with a billing item at the beginning' do
        let(:another_billing) { create(:billing, contract: contract) }
        let!(:another_billing_item) { create(:billing_item, begin_date: begin_date - 3, end_date: begin_date + 2, register: meter.registers.first, billing: another_billing) }

        it 'creates' do
          contract.register_meta.reload

          res = result
          expect(res).to be_success
          value = res.value!
          expect(value).to be_a Admin::BillingResource
          object = value.object
          expect(object.items.count).to eql 1
          item0 = object.items[0]
          item1 = another_billing_item
          expect(item0.begin_date).to eql item1.end_date
          expect(item0.end_date).to eql end_date
        end
      end

      context 'with a billing item at the end' do
        let(:another_billing) { create(:billing, contract: contract) }
        let!(:another_billing_item) { create(:billing_item, begin_date: end_date - 3, end_date: end_date + 2, register: meter.registers.first, billing: another_billing) }

        it 'creates' do
          contract.register_meta.reload

          res = result
          expect(res).to be_success
          value = res.value!
          expect(value).to be_a Admin::BillingResource
          object = value.object
          expect(object.items.count).to eql 1
          item0 = object.items[0]
          item1 = another_billing_item
          expect(item0.begin_date).to eql begin_date
          expect(item0.end_date).to eql item1.begin_date
        end
      end

    end

    context 'with a connected meter' do

      it 'creates' do
        mock_series_start = create_series(begin_date, 2000, 15.minutes,    10*1000*1000, 50*1000*1000, 4)
        mock_series_end   = create_series(last_date,   2000, 15.minutes, 1000*1000*1000, 50*1000*1000, 4)
        single_reading.next_api_request_single(contract.register_meta.register, begin_date, mock_series_start)
        single_reading.next_api_request_single(contract.register_meta.register, end_date, mock_series_end)

        res = result
        expect(res).to be_success
        value = res.value!
        expect(value).to be_a Admin::BillingResource
        object = value.object
        expect(object.items.count).to eql 1
        begin_reading = object.items.first.begin_reading
        end_reading = object.items.first.end_reading
        expect(begin_reading.value).to eql 1
        expect(end_reading.value).to eql 100
        invariant = object.items.first.invariant
        expect(invariant.errors.count).to eql 0
      end

    end

  end

  context 'with two tariffs' do

    before do
      contract.tariffs << tariff1
      contract.tariffs << tariff2
      contract.tariffs.reload
    end

    context 'without a connected meter' do

      it 'creates' do
        res = result
        expect(res).to be_success
        value = res.value!
        expect(value).to be_a Admin::BillingResource
        object = value.object
        expect(object.items.count).to eql 2
        expect(object.items[0].begin_reading).to be_nil
        expect(object.items[0].end_reading).to be_nil
        expect(object.items[1].begin_reading).to be_nil
        expect(object.items[1].end_reading).to be_nil
      end

    end

    context 'with a connected meter' do

      it 'creates' do
        mock_series_start  = create_series(begin_date,         2000, 15.minutes,    10*1000*1000, 50*1000*1000, 4)
        mock_series_middle = create_series(tariff2.begin_date, 2000, 15.minutes,   500*1000*1000, 50*1000*1000, 4)
        mock_series_end    = create_series(last_date,          2000, 15.minutes,  1000*1000*1000, 50*1000*1000, 4)
        single_reading.next_api_request_single(contract.register_meta.register, begin_date, mock_series_start)
        single_reading.next_api_request_single(contract.register_meta.register, tariff2.begin_date, mock_series_middle)
        single_reading.next_api_request_single(contract.register_meta.register, end_date, mock_series_end)

        res = result
        expect(res).to be_success
        value = res.value!
        expect(value).to be_a Admin::BillingResource
        object = value.object
        expect(object.items.count).to eql 2

        item0 = object.items[0]
        item1 = object.items[1]
        # verify tariffs
        expect(item0.tariff.id).to eql tariff1.id
        expect(item1.tariff.id).to eql tariff2.id

        # verify dates
        expect(item0.begin_date).to eql begin_date
        expect(item0.end_date).to eql tariff2.begin_date
        expect(item1.begin_date).to eql tariff2.begin_date
        expect(item1.end_date).to eql end_date

        # verify readings
        expect(item0.begin_reading.value).to eql 1
        expect(item0.end_reading.value).to eql 50

        expect(item1.begin_reading.value).to eql 50
        expect(item1.end_reading.value).to eql 100

        invariant = object.items.first.invariant
        expect(invariant.errors.count).to eql 0
      end

    end

  end



end
