require_relative '../../../support/discovergy_helper'

describe Transactions::Admin::Reading::Request do

  before(:each) do
    Import.global('services.redis_cache').flushall
  end

  let!(:localpool) { create(:group, :localpool) }
  let(:operator) { create(:account, :buzzn_operator) }
  let!(:localpoolr) { Admin::LocalpoolResource.all(operator).retrieve(localpool.id) }

  let(:meter) do
    create(:meter, :real, :connected_to_discovergy, :one_way, group: localpool)
  end

  let(:registerr) do
    localpoolr.meters.retrieve(meter.id).registers.first
  end

  let(:register) do
    registerr.object
  end

  let(:now) do
    Date.today.to_time
  end

  let(:params) do
    {
      date: now.to_json
    }
  end

  entity(:single_reading) do
    Import.global('services.datasource.discovergy.single_reading')
  end

  let(:result) do
    Transactions::Admin::Reading::Request.new.(resource: registerr,
                                               params: params)
  end

  context 'there is not a reading yet' do

    it 'works' do
      mock_series_start = create_series(now-5.minutes, 2000, 15.minutes, 10*1000*1000, 50*1000*1000, 4)
      single_reading.next_api_request_single(register, now, mock_series_start)
      expect(result).to be_success
    end

  end

end
