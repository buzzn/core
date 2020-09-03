require_relative 'test_admin_localpool_roda'

describe Admin::AccountingRoda, :request_helper, order: :defined do

  before(:all) do
    create(:vat, amount: 0.19, begin_date: Date.new(2000, 1, 1))
  end

  def app
    TestAdminLocalpoolRoda # this defines the active application for this test
  end

  entity(:localpool) { create(:group, :localpool) }
  entity(:contract) do
    create(:contract, :localpool_powertaker, :with_tariff,
           contractor: Organization::Market.buzzn,
           localpool: localpool)
  end

  entity!(:payment_1) { create(:payment, contract: contract) }

  let(:base_path) do
    "/localpools/#{localpool.id}/contracts/#{contract.id}/payments"
  end

  context 'list' do
    let(:path) { base_path }

    context 'POST' do
      let(:params) do
        {
          begin_date: Date.new(2018, 5, 23),
          price_cents: 1377,
          cycle: 'monthly',
          energy_consumption_kwh_pa: 777
        }
      end

      context 'unauthenticated' do
        it '403' do
          POST path, nil, params
          expect(response).to have_http_status(403)
        end
      end

      context 'authenticated' do
        it '201' do
          POST path, $admin, params
          expect(response).to have_http_status(201)
        end
      end
    end

    context 'GET ALL' do
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
        end
      end
    end
  end

  context 'id' do
    let(:path) { "#{base_path}/#{payment_1.id}"}

    context 'GET' do

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
        end
      end
    end

    context 'PATCH' do
      let(:params) do
        {
          updated_at: payment_1.updated_at.as_json,
        }
      end

      context 'unauthenticated' do
        it '403' do
          PATCH path, nil, params
          expect(response).to have_http_status(403)
        end
      end

      context 'authenticated' do
        it '200' do
          PATCH path, $admin, params
          expect(response).to have_http_status(200)
        end
      end
    end

    context 'DELETE' do

      context 'unauthenticated' do
        it '403' do
          DELETE path, nil
          expect(response).to have_http_status(403)
        end
      end

      context 'authenticated' do
        it '204' do
          DELETE path, $admin
          expect(response).to have_http_status(204)
        end
      end
    end

  end
end
