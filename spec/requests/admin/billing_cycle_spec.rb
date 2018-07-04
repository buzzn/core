require_relative 'test_admin_localpool_roda'
require_relative 'shared_crud'

describe Admin::BillingCycleResource, :request_helper do

  def app
    TestAdminLocalpoolRoda # this defines the active application for this test
  end

  context 'GET' do

    let(:path) { "/localpools/#{localpool.id}/billing-cycles/#{billing_cycle.id}" }

    entity(:localpool) { create(:group, :localpool) }

    entity(:billing_cycle) { create(:billing_cycle, localpool: localpool) }

    entity(:meta_json) do
      { 'next_billing_cycle_begin_date' => billing_cycle.end_date.as_json }
    end

    let(:expected_json) do
      {
        'id'=>billing_cycle.id,
        'type'=>'billing_cycle',
        'updated_at'=>billing_cycle.updated_at.as_json,
        'name'=>billing_cycle.name,
        'begin_date'=>billing_cycle.begin_date.as_json,
        'last_date'=>billing_cycle.last_date.as_json
      }
    end

    it_behaves_like 'single', :billing_cycle,
                    path: :path,
                    expected: :expected_json
    it_behaves_like 'all',
                    path: :path,
                    expected: :expected_json,
                    meta: :meta_json
  end

  context 'POST' do

    let(:path) { "/localpools/#{localpool.id}/billing-cycles" }

    entity(:localpool) { create(:group, :localpool) }

    let(:expected_errors) do
      {
        'name'=>['size cannot be greater than 64'],
        'last_date'=>['must be a date']
      }
    end

    let(:expected_json) do
      {
        'type'=>'billing_cycle',
        'name'=>'mine',
        'begin_date'=> localpool.start_date.as_json,
        'last_date'=> '2018-02-01'
      }
    end

    it_behaves_like 'create',
                    BillingCycle,
                    path: :path,
                    wrong: { last_date: 'blubla', name: 'something' * 10 },
                    params: { last_date: '2018-02-01', name: 'mine' },
                    expected: :expected_json,
                    errors: :expected_errors

  end

  context 'PATCH' do

    entity(:localpool) { create(:group, :localpool) }

    entity(:billing_cycle) { create(:billing_cycle, localpool: localpool) }

    let(:path) { "/localpools/#{localpool.id}/billing-cycles/#{billing_cycle.id}" }
    let(:expected_error_json) do
      {
        'updated_at'=>['is missing'],
        'name'=>['size cannot be greater than 64'],
        'last_date'=>['must be a date']
      }
    end

    entity :expected_json do
      {
        'type'=>'billing_cycle',
        'name'=>'abcd',
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
end
