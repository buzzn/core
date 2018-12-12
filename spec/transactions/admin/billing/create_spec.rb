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

  let(:contract) do
    create(:contract, :localpool_powertaker, :with_tariff,
           customer: person,
           register_meta: meter.registers.first.meta,
           contractor: Organization::Market.buzzn,
           localpool: localpool)
  end

  let!(:billingsr) do
    localpoolr.contracts.retrieve(contract.id).billings
  end

  let(:begin_date) { contract.begin_date }
  let(:end_date)   { begin_date + 90 }

  let(:params) do
    {
      :begin_date => begin_date,
      :end_date => end_date,
    }
  end

  # inject some fake readings
  entity(:single_reading) do
    Import.global('services.datasource.discovergy.single_reading')
  end 

  let(:result) do
    Transactions::Admin::Billing::Create.new.(resource: billingsr,
                                              params: params,
                                              parent: contract)
  end

  context 'without a connected meter' do

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

  context 'with a connected meter' do

    it 'creates' do
      mock_series_start = create_series(begin_date, 2000, 15.minutes,   10*1000*1000, 50*1000*1000, 4)
      mock_series_end   = create_series(end_date,   2000, 15.minutes, 1000*1000*1000, 50*1000*1000, 4)
      single_reading.next_api_request_single(contract.register_meta.register, begin_date.to_time, mock_series_start)
      single_reading.next_api_request_single(contract.register_meta.register, end_date.to_time, mock_series_end)

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
