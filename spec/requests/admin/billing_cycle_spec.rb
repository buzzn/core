require_relative 'test_admin_localpool_roda'
require_relative 'shared_crud'

describe Admin::BillingCycleRoda, :request_helper do

  def app
    TestAdminLocalpoolRoda # this defines the active application for this test
  end

  context 'GET' do

    let(:path) { "/localpools/#{localpool.id}/billing-cycles/#{billing_cycle.id}" }

    entity(:localpool) { create(:group, :localpool) }

    entity(:billing_cycle) { create(:billing_cycle, localpool: localpool) }

    let(:expected_json) do
      {   
        'id'=>billing_cycle.id,
        'type'=>'billing_cycle',
        'created_at'=>billing_cycle.created_at.as_json,
        'updated_at'=>billing_cycle.updated_at.as_json,
        'name'=>billing_cycle.name,
        'status'=>billing_cycle.status,
        'begin_date'=>billing_cycle.begin_date.as_json,
        'last_date'=>billing_cycle.last_date.as_json
      }
    end

    it_behaves_like 'single', :billing_cycle,
                    path: :path,
                    expected: :expected_json
    it_behaves_like 'all',
                    path: :path,
                    expected: :expected_json
  end

  context 'POST' do

    let(:path) { "/localpools/#{localpool.id}/billing-cycles" }

    let(:localpool) { create(:group, :localpool, gap_contract_customer: create(:person)) }
    let!(:lpc) { create(:contract, :localpool_processing, localpool: localpool)}
    let!(:tariff) do
      t = create(:tariff, group: localpool)
      localpool.gap_contract_tariffs << t
      t
    end

    let(:expected_errors) do
      { 'errors'=>{
        'name'=>['size cannot be greater than 64'],
        'last_date'=>['must be a date']}
      }
    end

    let(:expected_json) do
      {
        'type'=>'billing_cycle',
        'name'=>'mine',
        'begin_date'=> localpool.start_date.as_json,
        'last_date'=> '2018-02-01',
        'status'=>'open'
      }
    end

    it_behaves_like 'create',
                    BillingCycle,
                    path: :path,
                    wrong: { last_date: 'blubla', name: 'something' * 10 },
                    params: { last_date: '2018-02-01', name: 'mine' },
                    expected: :expected_json,
                    errors: :expected_errors

    it 'fails without a start date' do
      start_date = localpool.start_date
      localpool.start_date = nil
      localpool.save
      POST path, $admin, { last_date: '2018-08-02', name: 'shouldntwork'}
      expect(response).to have_http_status(422)
      localpool.start_date = start_date
      localpool.save
    end

  end

  context 'PATCH' do

    entity(:localpool) { create(:group, :localpool) }

    entity(:billing_cycle) { create(:billing_cycle, localpool: localpool) }

    let(:path) { "/localpools/#{localpool.id}/billing-cycles/#{billing_cycle.id}" }
    let(:expected_error_json) do
      { 'errors'=>{
        'updated_at'=>['is missing'],
        'name'=>['size cannot be greater than 64'],
        'last_date'=>['must be a date']}
      }
    end

    entity :expected_json do
      {
        'type'=>'billing_cycle',
        'name'=>'abcd',
        'status'=>billing_cycle.status,
        'begin_date'=>billing_cycle.begin_date.to_s,
        'last_date'=>billing_cycle.last_date.to_s
      }
    end

    it_behaves_like 'update', :billing_cycle,
                    path: :path,
                    wrong: {name: 'hello mister' * 20, last_date: 'blubla'},
                    params: {name: 'abcd', last_date: '2018-02-01'},
                    errors: :expected_error_json,
                    expected: :expected_json

  end

  context 'DELETE' do

    entity(:localpool) { create(:group, :localpool) }

    entity!(:other_billing_cycle) { create(:billing_cycle, localpool: localpool) }

    let(:path) { "/localpools/#{localpool.id}/billing-cycles/#{other_billing_cycle.id}" }

    it_behaves_like 'delete', :other_billing_cycle, path: :path

  end

  context 'bars' do

    let(:localpool) { create(:group, :localpool) }
    let(:billing_cycle) { create(:billing_cycle, localpool: localpool) }

    let(:path) { "/localpools/#{localpool.id}/billing-cycles/#{billing_cycle.id}/bars" }

    it 'works' do
      GET path, $admin
      expect(response).to have_http_status(200)
      # FIXME: check for content
    end

  end

end
