describe 'Services::UnbilledBillingItemsFactory' do

  before(:all) do
    create(:vat, amount: 0.19, begin_date: Date.new(2000, 1, 1))
  end

  let(:vat) do
    Vat.find(Date.new(2000, 01, 01))
  end

  let(:date_range)       { Date.new(2017, 1, 1)...Date.new(2018, 1, 1) }
  let(:args)             { { date_range: date_range, register_metas: register_metas, vat: vat} }
  let(:register_metas) do
    meta = create(:register, :real, :consumption).meta
    create(:contract, :localpool_powertaker, register_meta: meta)
    [meta]
  end
  subject { Services::UnbilledBillingItemsFactory.new.call(args) }

  context 'when group has no market locations' do
    let(:register_metas) { [] }
    it 'returns an empty array' do
      expect(subject).to eq([])
    end
  end

  context 'when group has one market location' do

    context 'when market location has one contract' do

      context 'when contract has no existing billings' do

        it 'contains one bar for the whole date range' do
          # expect(subject.size).to eq(1)
          expect(subject.first[:register_meta]).to eq(register_metas.first)
          item = subject.first[:contracts].first[:items].first
          expect(item).to have_attributes(
            date_range: args[:date_range],
            status: 'open',
            contract_type: 'power_taker'
          )
        end
      end

      context 'when contract has an existing billing' do
        let(:already_billed_date_range) { date_range.first...date_range.last - 2.months }
        let(:existing_billing)          { create(:billing, date_range: already_billed_date_range, contract: register_metas.first.contracts.last) }
        let!(:existing_bar)             { create(:billing_item, billing: existing_billing, vat: vat) }

        it 'contains one item for the correct date range' do
          item = subject.first[:contracts].first[:items].first
          expect(item).to have_attributes(
            date_range: already_billed_date_range.last...date_range.last,
            status: 'open',
            contract_type: 'power_taker'
          )
        end
      end
    end

    context 'when market location has two contracts' do
      let(:register_meta) { create(:register, :real, :consumption).meta }
      let(:register_metas) { [register_meta] }
      let!(:contracts) do
        [create(:contract, :localpool_gap, begin_date: date_range.first - 1.month, end_date: date_range.first + 1.month, register_meta: register_meta),
         create(:contract, :localpool_powertaker, begin_date: date_range.first + 1.month, end_date: nil, register_meta: register_meta)]
      end

      it 'returns two billing items' do
        expect(subject.size).to eq(1)
        expect(subject.first[:contracts].size).to eq(2)
        item1 = subject.first[:contracts].first[:items].first
        item2 = subject.first[:contracts].second[:items].first
        expect(item1).to have_attributes(
          date_range: date_range.first...(date_range.first + 1.month),
          status: 'open',
          contract_type: 'gap'
        )
        expect(item2).to have_attributes(
          date_range: (date_range.first + 1.month)...date_range.last,
          status: 'open',
          contract_type: 'power_taker'
        )
      end
    end
  end

end
