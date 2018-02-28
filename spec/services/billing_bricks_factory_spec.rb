describe 'Services::BillingBricksFactory' do

  describe 'bricks_by_market_location' do

    let(:group)      { build(:localpool) }
    let(:begin_date) { Date.new(2018, 1, 1) }
    let(:end_date)   { Date.new(2019, 1, 1) }
    let(:args)       { { date_range: begin_date..end_date, group: group } }
    subject          { Services::BillingBricksFactory.bricks_by_market_location(args) }

    context 'when group has no market locations' do
      let(:group) { create(:localpool, market_locations: []) }
      it 'returns an empty array' do
        expect(subject).to eq([])
      end
    end

    context 'when group has one market location' do
      context 'when market location has one contract and register' do
        let(:register)        { create(:register, :consumption, :with_market_location) }
        let(:market_location) { create(:market_location, :with_contract, register: register) }
        let(:group)           { create(:localpool, market_locations: [market_location]) }

        it 'returns one market location' do
          expect(subject.size).to eq(1)
          expect(subject.first[:market_location]).to eq(market_location)
        end

        it 'contains one brick for the whole date range' do

          expect(subject.first[:bricks].size).to equal(1)
          expected_brick = BillingBrick.new(
            begin_date: args[:date_range].first,
            end_date: args[:date_range].last,
            status: :open,
            type: :power_taker,
            market_location: market_location
          )
          expect(subject.first[:bricks].size).to eq(1)
          expect(subject.first[:bricks].first).to eq(expected_brick)
        end

        context 'when market location has two contracts' do
          let(:contracts) do
            [create(:contract, :localpool_gap, begin_date: begin_date - 1.month, end_date: begin_date + 1.month),
             create(:contract, :localpool_powertaker, begin_date: begin_date + 1.month, end_date: nil)]
          end
          let(:market_location) { create(:market_location, contracts: contracts, register: register) }

          it 'returns one market location' do
            expect(subject.size).to eq(1)
            expect(subject.first[:market_location]).to eq(market_location)
          end

          it 'returns two bricks' do
            expect(subject.first[:bricks].size).to eq(2)
          end
        end
      end
    end
  end

end
