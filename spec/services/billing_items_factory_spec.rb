describe 'Services::BillingItemsFactory' do

  describe 'items_by_market_location' do

    let(:group)      { build(:localpool) }
    let(:date_range) { Date.new(2018, 1, 1)...Date.new(2019, 1, 1) }
    let(:args)       { { date_range: date_range, group: group } }
    subject          { Services::BillingItemsFactory.new.items_by_market_location(args) }

    context 'when group has no market locations' do
      let(:group) { create(:localpool, market_locations: []) }
      it 'returns an empty array' do
        expect(subject).to eq([])
      end
    end

    context 'when group has one market location' do

      context 'when market location has one contract' do

        context 'when contract has no existing billings' do
          let(:market_location) { create(:market_location, :with_contract, register: :consumption) }
          let(:group)           { create(:localpool, market_locations: [market_location]) }

          it 'returns one market location' do
            expect(subject.size).to eq(1)
            expect(subject.first[:market_location]).to eq(market_location)
          end

          it 'contains one item for the whole date range' do

            expect(subject.first[:items].size).to equal(1)
            expect(subject.first[:items].size).to eq(1)
            expect(subject.first[:items].first).to have_attributes(
              date_range:      args[:date_range],
              status:          'open',
              contract_type:   'power_taker'
            )
          end
        end

        context 'when contract has an existing billing' do
          let(:market_location)           { create(:market_location, :with_contract, register: :consumption) }
          let(:group)                     { create(:localpool, market_locations: [market_location]) }
          let(:already_billed_date_range) { date_range.first...date_range.last - 2.months }
          let(:existing_billing)          { create(:billing, date_range: already_billed_date_range, contract: market_location.contracts.last) }
          let!(:existing_item)           { create(:billing_item, billing: existing_billing) }

          it 'contains one item for the existing billing and a new one' do
            expect(subject.first[:items].size).to eq(2)
            item1, item2 = subject.first[:items]
            expect(item1.date_range).to eq(existing_item.date_range)
            expect(item2.date_range).to eq(already_billed_date_range.last...date_range.last)
            expect(item2.status).to eq('open')
          end
        end
      end

      context 'when market location has two contracts' do
        let(:contracts) do
          [create(:contract, :localpool_gap, begin_date: date_range.first - 1.month, end_date: date_range.first + 1.month),
           create(:contract, :localpool_powertaker, begin_date: date_range.first + 1.month, end_date: nil)]
        end
        let!(:market_location) { create(:market_location, contracts: contracts, register: :consumption) }
        let(:group)            { create(:localpool, market_locations: [market_location]) }

        it 'returns one market location' do
          expect(subject.size).to eq(1)
          expect(subject.first[:market_location]).to eq(market_location)
        end

        it 'returns two items' do
          expect(subject.first[:items].size).to eq(2)
          item1, item2 = subject.first[:items]
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

end
