require_relative 'test_admin_localpool_roda'

describe Admin::AccountingRoda, :request_helper do

  def app
    TestAdminLocalpoolRoda # this defines the active application for this test
  end

  entity(:localpool) { create(:group, :localpool) }
  entity(:contract) do
    create(:contract, :localpool_powertaker, :with_tariff,
           contractor: Organization::Market.buzzn,
           localpool: localpool)
  end

  let(:base_path) do
    "/localpools/#{localpool.id}/contracts/#{contract.id}/accounting/"
  end

  let(:params) do
    {
      :amount => 777,
      :comment => 'foo'
    }
  end

  context 'unauthenticated' do
    it '403' do
      POST base_path + 'book'
      expect(response).to have_http_status(403)
    end

    it '403' do
      GET base_path + 'balance_sheet'
      expect(response).to have_http_status(403)
    end
  end

  context 'authenticated', order: :defined do
    it '200' do
      POST base_path + 'book', $admin, params
      expect(response).to have_http_status(201)
    end

    it 'retrieves balance sheet' do
      GET base_path + 'balance_sheet?include=entries', $admin
      expect(response).to have_http_status(200)
      expect(json['total']).to eql 777
      expect(json['entries'].count).to eql 1
    end
  end

end
