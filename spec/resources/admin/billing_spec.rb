describe Admin::BillingResource do

  before(:all) do
    create(:vat, amount: 0.19, begin_date: Date.new(2000, 1, 1))
  end

  let(:vat) do
    Vat.find(Date.new(2000, 01, 01))
  end

  entity(:admin) { create(:account, :buzzn_operator) }
  entity(:localpool) { create(:group, :localpool) }
  entity(:contract) do
    create(:contract, :localpool_powertaker, :with_tariff, localpool: localpool)
  end
  entity(:billing) do
    create(:billing, contract: contract)
  end
  let!(:billing_item) do
    create(:billing_item,
           billing: billing,
           tariff: billing.contract.tariffs.first,
           vat: vat)

  end

  let(:billing_resource) { Admin::LocalpoolResource.all(admin).retrieve(localpool.id).contracts.retrieve(contract.id).billings.first }

  it 'works' do
    expect(billing_resource).to be_a Admin::BillingResource
  end

  subject { JSON.parse(billing_resource.to_json) }

  context 'calculated' do
    before do
      billing.status = :calculated
      billing.save
    end

    it 'does not allow without payment' do
      expect(subject['allowed_actions']['update']).not_to be_nil
      expect(subject['allowed_actions']['update']['status']).not_to be_nil
      expect(subject['allowed_actions']['update']['status']['void']).to eql true
      expect(subject['allowed_actions']['update']['status']['calculated']).to eql true
      expect(subject['allowed_actions']['update']['status']['documented']).not_to eql true
      expect(subject['allowed_actions']['update']['status']['documented'].to_s).to eql '{"contract"=>{"current_payment"=>["must be filled"], "localpool"=>{"fake_stats"=>["must be filled"]}}}'
    end

  end

end
