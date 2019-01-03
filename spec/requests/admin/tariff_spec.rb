require_relative 'test_admin_localpool_roda'
require_relative 'shared_crud'

describe Admin::LocalpoolRoda, :request_helper do

  def app
    TestAdminLocalpoolRoda # this defines the active application for this test
  end

  context 'tariffs' do

    context 'GET' do

      entity(:localpool) { create(:group, :localpool) }

      entity!(:tariff) { create(:tariff, group: localpool, contracts: [create(:contract, localpool: localpool)]) }

      let(:tariff_json) do
        {
          'id'=>tariff.id,
          'type'=>'contract_tariff',
          'created_at' => tariff.created_at.as_json,
          'updated_at' => tariff.updated_at.as_json,
          'name'=>tariff.name,
          'begin_date'=>tariff.begin_date.to_s,
          'energyprice_cents_per_kwh'=>tariff.energyprice_cents_per_kwh,
          'baseprice_cents_per_month'=>tariff.baseprice_cents_per_month,
          'number_of_contracts' => 1,
          'updatable'=>false,
          'deletable'=>false
        }
      end

      let(:path) {"/localpools/#{localpool.id}/tariffs/#{tariff.id}" }

      it_behaves_like 'single', :tariff, expected: :tariff_json, path: :path
      it_behaves_like 'all', expected: :tariff_json, path: :path

    end

    context 'DELETE' do

      entity(:localpool) { create(:group, :localpool) }

      entity(:other_tariff) do
        create(:tariff, group: localpool, begin_date: Date.new(2016, 1, 1))
      end

      let(:path) {"/localpools/#{localpool.id}/tariffs/#{other_tariff.id}" }

      it_behaves_like 'delete', :other_tariff, path: :path
    end

    context 'POST' do

      let(:wrong_json) do
        {
          'name'=>['size cannot be greater than 64'],
          'begin_date'=>['must be a date'],
          'energyprice_cents_per_kwh'=>['must be a float'],
          'baseprice_cents_per_month'=>['must be a float']
        }
      end

      let(:created_json) do
        {
          'type'=>'contract_tariff',
          'name'=>'special',
          'begin_date'=> '2016-02-01',
          'energyprice_cents_per_kwh'=>23.66,
          'baseprice_cents_per_month'=>500.0,
          'number_of_contracts' => 0,
          'updatable'=>false,
          'deletable'=>true
        }
      end

      entity(:localpool) { create(:group, :localpool) }

      let(:path) {"/localpools/#{localpool.id}/tariffs" }

      it_behaves_like 'create', Contract::Tariff,
                      path: :path,
                      wrong: {
                        name: 'Max Mueller' * 10,
                        begin_date: 'heute-hier-morgen-dort',
                        energyprice_cents_per_kwh: 'not so much',
                        baseprice_cents_per_month: 'limitless'
                      },
                      params: {
                        'name'=>'special',
                        'begin_date'=> '2016-02-01',
                        'energyprice_cents_per_kwh'=>23.66,
                        'baseprice_cents_per_month'=>500.0,
                      },
                      errors: :wrong_json,
                      expected: :created_json
    end
  end
end
