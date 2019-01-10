require_relative 'test_admin_localpool_roda'
require_relative 'shared_crud'

describe Admin::LocalpoolRoda, :request_helper do

  def app
    TestAdminLocalpoolRoda # this defines the active application for this test
  end

  entity!(:localpool) { create(:group, :localpool) }

  let(:path) { "/localpools/#{localpool.id}/gap-contract-tariffs" }

  let(:today) do
    Date.today
  end

  let!(:tariff_1) do
    create(:tariff, group: localpool, begin_date: today)
  end

  let!(:tariff_2) do
    create(:tariff, group: localpool, begin_date: today+30)
  end

  let!(:tariff_3) do
    create(:tariff, group: localpool, begin_date: today+32)
  end

  context 'GET' do
    before do
      localpool.gap_contract_tariffs = [tariff_1, tariff_2, tariff_3]
    end

    context 'unauthenticated' do
      it '403' do
        GET path
        expect(response).to have_http_status(403)
      end
    end

    context 'authenticated' do
      it '200' do
        GET path, $admin
        expect(response).to have_http_status(200)
        expect(json['array']).not_to be_nil
        content = json['array']
        expect(content.first['type']).to eql 'contract_contexted_tariff'
        expect(content.count).to eql 3
      end
    end

  end

  context 'PATCH' do
    let(:params) do
      localpool.reload
      {
        tariff_ids: [tariff_1.id, tariff_2.id],
        updated_at: localpool.updated_at.to_json
      }
    end

    context 'unauthenticated' do
      it '403' do
        PATCH path, nil, params
        expect(response).to have_http_status(403)
      end
    end

    context 'authenticated' do
      it '201' do
        PATCH path, $admin, params
        expect(response).to have_http_status(200)
        localpool.reload
        expect(localpool.gap_contract_tariffs.pluck(:id)).to eql [tariff_1.id, tariff_2.id]
      end
    end

  end

end
