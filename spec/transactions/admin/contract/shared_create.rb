shared_examples 'without processing contract' do |transaction|

  let(:result) do
    transaction.(resource: r, params: params, localpool: lp)
  end

  it 'does not create' do
    expect(lp.localpool_processing_contracts.count).to eql 0
    expect {result}.to raise_error Buzzn::ValidationError
  end

end

shared_examples 'with existing contract on same register' do |transaction|

  let!(:begin_date) { Date.today }
  let!(:end_date) { Date.today + 30 }

  let!(:begin_date_new) { begin_date + 10 }

  let!(:register_meta) { create(:meta) }
  let!(:lpc) do
    unless lp.localpool_processing_contracts.any?
      create(:contract, :localpool_processing,
             customer: lp.object.owner,
             contractor: Organization::Market.buzzn,
             localpool: lp.object)
    end
    lp.object.reload
    lp.localpool_processing_contracts.first
  end

  let!(:other_contract) do
    lpc
    create(:contract, :localpool_powertaker,
           register_meta: register_meta,
           localpool: lp.object,
           begin_date: begin_date,
           termination_date: nil,
           end_date: end_date)
  end

  let(:params_modified) do
    p = params.dup
    p[:begin_date] = begin_date_new
    p[:register_meta] = { id: register_meta.id }
    p
  end

  let(:result) do
    transaction.(resource: r, params: params_modified, localpool: lp)
  end

  it 'does not create' do
    expect {result}.to raise_error(Buzzn::ValidationError, "{:register_meta=>[{:error=>\"other_contract_active_at_begin\", :contract_id=>#{other_contract.id}}]}")
  end

end
